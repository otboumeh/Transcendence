import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

export const errorRate = new Rate('errors');

export const options = {
  scenarios: {
    ramping_load: {
      executor: 'ramping-arrival-rate',
      startRate: 1,
      timeUnit: '1s',
      preAllocatedVUs: 10,
      maxVUs: 100,
      stages: [
        { duration: '30s', target: 10 },  // Ramp up to 10 RPS
        { duration: '1m', target: 10 },   // Stay at 10 RPS
        { duration: '30s', target: 20 },  // Ramp up to 20 RPS
        { duration: '1m', target: 20 },   // Stay at 20 RPS
        { duration: '30s', target: 0 },   // Ramp down to 0 RPS
      ],
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<1000', 'p(99)<1500'], // 95% under 1s, 99% under 1.5s
    errors: ['rate<0.1'],                            // Error rate < 10%
  },
};

const BASE_URL = 'http://localhost';

export default function () {
  const responses = {
    home: http.get(`${BASE_URL}/`),
    health: http.get(`${BASE_URL}/api/health`),
    static: http.get(`${BASE_URL}/dist/assets/index.css`),
  };

  // Check responses
  check(responses.home, {
    'home status is 200': (r) => r.status === 200,
    'home has correct content type': (r) => r.headers['Content-Type'].includes('text/html'),
  });

  check(responses.health, {
    'health status is 200': (r) => r.status === 200,
    'health returns OK': (r) => r.body.includes('OK'),
  });

  check(responses.static, {
    'static status is 200': (r) => r.status === 200,
    'static has correct content type': (r) => r.headers['Content-Type'].includes('text/css'),
  });

  sleep(1);
}