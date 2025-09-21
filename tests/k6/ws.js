import ws from 'k6/ws';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

export const errorRate = new Rate('errors');
export const latencyTrend = new Trend('ws_latency');

export const options = {
  vus: 10,
  duration: '30s',
  thresholds: {
    ws_latency: ['p(95)<100'],  // 95% of messages under 100ms
    errors: ['rate<0.1'],       // Error rate < 10%
  },
};

export default function () {
  const url = 'ws://localhost/ws';
  const params = {
    headers: {
      'Sec-WebSocket-Key': 'test',
      'Sec-WebSocket-Version': '13',
    },
  };

  const res = ws.connect(url, params, function (socket) {
    socket.on('open', () => {
      console.log('Connected');
      
      // Send ping message
      const startTime = new Date().getTime();
      socket.send(JSON.stringify({ type: 'ping', timestamp: startTime }));
    });

    socket.on('message', (data) => {
      const message = JSON.parse(data);
      if (message.type === 'pong') {
        const latency = new Date().getTime() - message.timestamp;
        latencyTrend.add(latency);
      }
    });

    socket.on('error', (e) => {
      console.error('Error: ', e);
      errorRate.add(1);
    });

    // Keep connection alive for a few seconds
    sleep(5);
  });

  check(res, { 'status is 101': (r) => r && r.status === 101 });
}