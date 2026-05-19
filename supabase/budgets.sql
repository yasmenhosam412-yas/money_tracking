-- Run in Supabase SQL editor (Dashboard → SQL).

create table if not exists public.budgets (
  budget_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  category text not null,
  amount double precision not null check (amount > 0),
  year int not null,
  month int not null check (month between 1 and 12),
  created_at timestamptz not null default now(),
  unique (user_id, category, year, month)
);

create index if not exists budgets_user_period_idx
  on public.budgets (user_id, year, month);

alter table public.budgets enable row level security;

drop policy if exists "Users can read own budgets" on public.budgets;
create policy "Users can read own budgets"
  on public.budgets for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert own budgets" on public.budgets;
create policy "Users can insert own budgets"
  on public.budgets for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update own budgets" on public.budgets;
create policy "Users can update own budgets"
  on public.budgets for update
  using (auth.uid() = user_id);

drop policy if exists "Users can delete own budgets" on public.budgets;
create policy "Users can delete own budgets"
  on public.budgets for delete
  using (auth.uid() = user_id);
