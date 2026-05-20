-- Run in Supabase SQL editor (Dashboard → SQL).
-- Links each expense to an income "wallet" for per-source remaining balance.

alter table public.expenses
  add column if not exists income_source text;

comment on column public.expenses.income_source is
  'Optional income source / wallet this expense is deducted from (matches incomes.category).';
