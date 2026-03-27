const express = require('express');
const cors = require('cors');
const axios = require('axios');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 8787);
const sparkApiPassword = process.env.SPARK_API_PASSWORD;
const sparkUrl = 'https://spark-api-open.xf-yun.com/v1/chat/completions';

app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/health', (_req, res) => {
  res.status(200).json({ ok: true });
});

app.post('/api/llm/chat/stream', async (req, res) => {
  if (!sparkApiPassword) {
    res.status(500).json({ code: 'MISSING_SERVER_SECRET' });
    return;
  }

  const messages = req.body?.messages;
  if (!Array.isArray(messages) || messages.length === 0) {
    res.status(400).json({ code: 'INVALID_MESSAGES' });
    return;
  }

  const payload = {
    model: req.body?.model || 'lite',
    messages,
    stream: true,
  };

  try {
    const upstream = await axios.post(sparkUrl, payload, {
      headers: {
        Authorization: `Bearer ${sparkApiPassword}`,
        'Content-Type': 'application/json',
        Accept: 'text/event-stream',
      },
      responseType: 'stream',
      timeout: 0,
      validateStatus: () => true,
    });

    const contentType = upstream.headers['content-type'] || 'text/event-stream; charset=utf-8';
    res.status(upstream.status);
    res.setHeader('Content-Type', contentType);
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    req.on('close', () => {
      upstream.data.destroy();
    });

    upstream.data.on('error', () => {
      if (!res.writableEnded) {
        res.end();
      }
    });

    upstream.data.pipe(res);
  } catch (_error) {
    if (!res.headersSent) {
      res.status(502).json({ code: 'UPSTREAM_REQUEST_FAILED' });
      return;
    }
    if (!res.writableEnded) {
      res.end();
    }
  }
});

app.listen(port, () => {
  process.stdout.write(`LLM proxy server listening on http://localhost:${port}\n`);
});
