import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import Parser from "rss-parser";

admin.initializeApp();
const db = admin.firestore();

const parser = new Parser();
const RSS_FEED_URLS = [
  "https://rss.itmedia.co.jp/rss/2.0/news_bursts.xml",     // ✅ ITmedia：安定版に変更済
  "https://japan.cnet.com/rss/index.rdf",                  // ✅ CNET Japan（そのまま）
  "https://tech.nikkeibp.co.jp/rss/nxt/rss_all.xml"        // ✅ 日経クロステック：有効URLに変更
];

const AI_KEYWORDS = ["AI", "人工知能", "ChatGPT", "生成AI", "機械学習", "深層学習", "LLM", "MCP", "Claude", "Gemini", "cursor", "プロンプト", "OpenAI"];

function isAIContent(title: string, description: string): boolean {
  return (
    AI_KEYWORDS.some(k => title.toLowerCase().includes(k.toLowerCase())) ||
    AI_KEYWORDS.some(k => description.toLowerCase().includes(k.toLowerCase()))
  );
}

export const fetchNewsEveryHour = onSchedule("every 60 minutes", async () => {
  logger.info("📰 Fetching multiple RSS feeds...");

  const allItems: any[] = [];
  let added = 0;

  // Parse all RSS feeds in parallel
  const feeds = await Promise.all(
    RSS_FEED_URLS.map(async (url) => {
      try {
        logger.info(`🌐 Fetching: ${url}`);
        return await parser.parseURL(url);
      } catch (error) {
        logger.error(`❌ Failed to fetch ${url}: ${error}`);
        return { items: [] };
      }
    })
  );

  feeds.forEach(feed => {
    allItems.push(...(feed.items || []));
  });

  for (const item of allItems) {
    const title = item.title ?? "";
    const description = item.contentSnippet ?? item.summary ?? "";
    const link = item.link ?? "";
    const publishedAt = item.isoDate ? new Date(item.isoDate) : new Date();

    // check if AI-related
    if (!isAIContent(title, description)) {
      logger.info(`⏭️ Skipped non-AI news: ${title}`);
      continue;
    }

    // image logic
    let imageUrl = item.enclosure?.url
      || item["media:content"]?.url
      || item["media:thumbnail"]?.url
      || (() => {
        const match = item.content?.match(/<img[^>]+src="([^">]+)"/);
        return match ? match[1] : null;
      })();


    const existing = await db.collection("news")
      .where("title", "==", title)
      .where("publishedAt", "==", publishedAt)
      .get();

    if (!existing.empty) {
      logger.info(`⏩ Skip duplicate: ${title}`);
      continue;
    }

    const docData: any = {
      title,
      description,
      link,
      publishedAt,
    };

    if (imageUrl) {
      docData.imageUrl = imageUrl;
    }

    await db.collection("news").add(docData);
    added++;

    logger.info(`✅ Saved: ${title}`);
  }

  logger.info(`🎉 Fetch complete. Total saved: ${added} items.`);
});