-- RoomMitra: shehar ke ilake (Google se ek baar laakar yaha jama hote hain)
create table if not exists public.city_areas (
  city text not null,
  name text not null,
  lat double precision not null,
  lng double precision not null,
  primary key (city, name)
);
alter table public.city_areas enable row level security;
drop policy if exists "Anyone reads city areas" on public.city_areas;
create policy "Anyone reads city areas" on public.city_areas for select to anon, authenticated using (true);
revoke all on public.city_areas from anon, authenticated;
grant select on public.city_areas to anon, authenticated;
