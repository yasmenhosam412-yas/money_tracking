-- Receipt photos, travel-currency entry metadata, and storage bucket.

alter table public.expenses
  add column if not exists receipt_url text,
  add column if not exists entry_currency text,
  add column if not exists entry_amount numeric;

alter table public.incomes
  add column if not exists entry_currency text,
  add column if not exists entry_amount numeric;

comment on column public.expenses.receipt_url is 'Public URL of receipt image in storage bucket receipts';
comment on column public.expenses.entry_currency is 'Currency code user entered (EGP, USD, EUR)';
comment on column public.expenses.entry_amount is 'Amount in entry_currency at time of entry';
comment on column public.incomes.entry_currency is 'Currency code user entered (EGP, USD, EUR)';
comment on column public.incomes.entry_amount is 'Amount in entry_currency at time of entry';

insert into storage.buckets (id, name, public)
values ('receipts', 'receipts', true)
on conflict (id) do nothing;

drop policy if exists "receipts_select_own" on storage.objects;
create policy "receipts_select_own"
on storage.objects for select to authenticated
using (
  bucket_id = 'receipts'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "receipts_insert_own" on storage.objects;
create policy "receipts_insert_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'receipts'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "receipts_delete_own" on storage.objects;
create policy "receipts_delete_own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'receipts'
  and (storage.foldername(name))[1] = auth.uid()::text
);
