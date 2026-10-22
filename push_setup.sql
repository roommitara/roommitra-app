-- RoomMitra: push notifications setup (Supabase SQL Editor me ek baar run karo)
create table if not exists public.device_tokens (
  token text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  city text not null default 'Nahan',
  lang text not null default 'hi',
  updated_at timestamptz not null default now()
);
create index if not exists device_tokens_city_idx on public.device_tokens (city);
alter table public.device_tokens enable row level security;
revoke all on public.device_tokens from anon, authenticated;

create table if not exists public.push_log (
  listing_id uuid primary key references public.room_listings(id) on delete cascade,
  sent_at timestamptz not null default now()
);
alter table public.push_log enable row level security;
revoke all on public.push_log from anon, authenticated;

create or replace function public.register_device(p_token text, p_city text, p_lang text)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'not signed in'; end if;
  if p_token is null or length(p_token) < 20 then raise exception 'bad token'; end if;
  insert into public.device_tokens(token, user_id, city, lang, updated_at)
  values (p_token, auth.uid(), left(coalesce(p_city,'Nahan'), 50), case when p_lang = 'en' then 'en' else 'hi' end, now())
  on conflict (token) do update
    set user_id = auth.uid(), city = excluded.city, lang = excluded.lang, updated_at = now();
end $$;
revoke all on function public.register_device(text, text, text) from public, anon;
grant execute on function public.register_device(text, text, text) to authenticated;
