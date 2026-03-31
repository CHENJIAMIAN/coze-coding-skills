import { createClient, SupabaseClient } from '@supabase/supabase-js';

declare global {
  interface Window {
    __SUPABASE_CONFIG__?: {
      url: string;
      anonKey: string;
    };
  }
}

const SUPABASE_CONFIG_READY_EVENT = 'supabase-config-ready';

let browserClient: SupabaseClient | null = null;

function waitForConfig(maxWait = 5000): Promise<boolean> {
  if (window.__SUPABASE_CONFIG__?.url && window.__SUPABASE_CONFIG__?.anonKey) {
    return Promise.resolve(true);
  }

  return new Promise((resolve) => {
    let resolved = false;

    const handler = () => {
      if (!resolved) {
        resolved = true;
        window.removeEventListener(SUPABASE_CONFIG_READY_EVENT, handler);
        resolve(true);
      }
    };

    window.addEventListener(SUPABASE_CONFIG_READY_EVENT, handler);

    setTimeout(() => {
      if (!resolved) {
        resolved = true;
        window.removeEventListener(SUPABASE_CONFIG_READY_EVENT, handler);
        resolve(window.__SUPABASE_CONFIG__?.url && window.__SUPABASE_CONFIG__?.anonKey ? true : false);
      }
    }, maxWait);
  });
}

function isConfigReady(): boolean {
  return !!(window.__SUPABASE_CONFIG__?.url && window.__SUPABASE_CONFIG__?.anonKey);
}

function getSupabaseBrowserClient(): SupabaseClient {
  if (browserClient === null) {
    const config = window.__SUPABASE_CONFIG__;

    if (!config || !config.url || !config.anonKey) {
      throw new Error(
        'Supabase config not found. Make sure SupabaseConfigProvider is included in your layout.tsx and use useSupabaseConfig() to wait for config to be ready.'
      );
    }

    browserClient = createClient(config.url, config.anonKey, {
      db: {
        timeout: 60000,
      },
      auth: {
        autoRefreshToken: true,
        persistSession: true,
      },
    });
  }

  return browserClient;
}

async function getSupabaseBrowserClientAsync(): Promise<SupabaseClient> {
  if (browserClient !== null) {
    return browserClient;
  }

  const ready = await waitForConfig();
  if (!ready) {
    throw new Error(
      'Supabase config not found after waiting. Make sure SupabaseConfigProvider is included in your layout.tsx'
    );
  }

  return getSupabaseBrowserClient();
}

export { getSupabaseBrowserClient, getSupabaseBrowserClientAsync, waitForConfig, isConfigReady };
