import { test, expect, type Page } from '@playwright/test';

test.describe('Transcendence App', () => {
  test.beforeEach(async ({ page }: { page: Page }) => {
    await page.goto('http://localhost');
  });

  test('should load home page', async ({ page }: { page: Page }) => {
    // Check title
    await expect(page).toHaveTitle(/Transcendence/);
    
    // Check main elements
    await expect(page.locator('nav')).toBeVisible();
    await expect(page.locator('main')).toBeVisible();
  });

  test('should handle WebSocket connection', async ({ page }: { page: Page }) => {
    // Create a promise that resolves when WS connects
    const wsPromise = page.waitForEvent('websocket');
    
    // Navigate to game page (or wherever WS is used)
    await page.click('text=Play');
    
    // Wait for WS connection
    const ws = await wsPromise;
    expect(ws.url()).toContain('/ws');
    
    // Optional: wait for specific WS messages
    const message = await ws.waitForEvent('framesent');
    expect(message).toBeTruthy();
  });

  test('should simulate basic login flow', async ({ page }: { page: Page }) => {
    // Go to login page
    await page.click('text=Login');
    
    // Fill login form
    await page.fill('input[name="username"]', 'testuser');
    await page.fill('input[name="password"]', 'testpass');
    
    // Click login and wait for navigation
    await Promise.all([
      page.waitForNavigation(),
      page.click('button:has-text("Login")')
    ]);
    
    // Verify logged in state
    await expect(page.locator('text=Profile')).toBeVisible();
  });
});