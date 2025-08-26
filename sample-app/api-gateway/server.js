const express = require('express');
const httpProxy = require('http-proxy-middleware');
const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(express.json());

// Health check endpoint
app.get('/api/gateway/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'api-gateway', 
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Proxy to user service
app.use('/api/users', httpProxy.createProxyMiddleware({
  target: process.env.USER_SERVICE_URL || 'http://user-service:3001',
  changeOrigin: true,
  pathRewrite: {
    '^/api/users': '/'
  },
  onError: (err, req, res) => {
    console.error('Proxy error:', err);
    res.status(503).json({ error: 'User service unavailable' });
  }
}));

// Proxy to product service
app.use('/api/products', httpProxy.createProxyMiddleware({
  target: process.env.PRODUCT_SERVICE_URL || 'http://product-service:5000',
  changeOrigin: true,
  pathRewrite: {
    '^/api/products': '/'
  },
  onError: (err, req, res) => {
    console.error('Proxy error:', err);
    res.status(503).json({ error: 'Product service unavailable' });
  }
}));

// Default route
app.get('/', (req, res) => {
  res.json({ 
    message: 'API Gateway for K8s Tutorial',
    endpoints: [
      '/api/gateway/health',
      '/api/users/*',
      '/api/products/*'
    ]
  });
});

app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
});
