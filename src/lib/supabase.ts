import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.SUPABASE_URL;
const supabaseKey = import.meta.env.SUPABASE_KEY;
const domainId = import.meta.env.DOMAIN_ID;

export const supabase = createClient(supabaseUrl, supabaseKey);

export interface BlogPost {
  id: string;
  title: string;
  slug: string;
  content: string;
  excerpt?: string;
  created_at: string;
  updated_at: string;
  status: string;
  domain_id: string;
}

export async function getAllPosts(): Promise<BlogPost[]> {
  try {
    // Fetch in smaller batches to avoid timeout
    const { data, error } = await supabase
      .from('domainblog_posts')
      .select('id,title,slug,excerpt,created_at,updated_at,content')
      .eq('domain_id', domainId)
      .eq('status', 'published')
      .order('created_at', { ascending: false })
      .limit(100); // Limit to avoid timeout on large datasets

    if (error) {
      console.error('Error fetching posts:', error);
      return [];
    }

    return data || [];
  } catch (err) {
    console.error('Exception fetching posts:', err);
    return [];
  }
}

export async function getPostBySlug(slug: string): Promise<BlogPost | null> {
  const { data, error } = await supabase
    .from('domainblog_posts')
    .select('*')
    .eq('domain_id', domainId)
    .eq('slug', slug)
    .eq('status', 'published')
    .single();

  if (error) {
    console.error('Error fetching post:', error);
    return null;
  }

  return data;
}

export async function getDomainInfo() {
  const { data, error } = await supabase
    .from('domainblog_domains')
    .select('id,url,name')
    .eq('id', domainId)
    .single();

  if (error) {
    console.error('Error fetching domain:', error);
    return null;
  }

  return data;
}
