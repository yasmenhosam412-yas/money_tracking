-- Association member invites: search users by username, send/respond to invites.
-- Run in Supabase SQL editor after associations.sql.

-- ---------------------------------------------------------------------------
-- Invites
-- ---------------------------------------------------------------------------

create table if not exists public.association_invites (
  id uuid primary key default gen_random_uuid(),
  association_id uuid not null references public.associations (id) on delete cascade,
  inviter_user_id uuid not null references auth.users (id) on delete cascade,
  invitee_user_id uuid not null references auth.users (id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'rejected', 'cancelled')),
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  expires_at timestamptz not null default (now() + interval '7 days'),
  constraint association_invites_no_self check (inviter_user_id <> invitee_user_id)
);

create unique index if not exists association_invites_one_pending
  on public.association_invites (association_id, invitee_user_id)
  where status = 'pending';

create index if not exists association_invites_invitee_idx
  on public.association_invites (invitee_user_id, status);

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function public.can_manage_association(p_association_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.association_members m
    join public.associations a on a.id = m.association_id
    where m.association_id = p_association_id
      and m.user_id = auth.uid()
      and m.role in ('owner', 'admin')
      and a.is_personal = false
  );
$$;

-- ---------------------------------------------------------------------------
-- RLS: invites
-- ---------------------------------------------------------------------------

alter table public.association_invites enable row level security;

drop policy if exists "Invitee read own invites" on public.association_invites;
create policy "Invitee read own invites"
  on public.association_invites for select
  using (invitee_user_id = auth.uid());

drop policy if exists "Managers read association invites" on public.association_invites;
create policy "Managers read association invites"
  on public.association_invites for select
  using (public.can_manage_association(association_id));

drop policy if exists "Managers insert invites" on public.association_invites;
create policy "Managers insert invites"
  on public.association_invites for insert
  with check (
    inviter_user_id = auth.uid()
    and public.can_manage_association(association_id)
  );

drop policy if exists "Invitee update own pending invites" on public.association_invites;
create policy "Invitee update own pending invites"
  on public.association_invites for update
  using (invitee_user_id = auth.uid() and status = 'pending')
  with check (invitee_user_id = auth.uid());

drop policy if exists "Managers cancel pending invites" on public.association_invites;
create policy "Managers cancel pending invites"
  on public.association_invites for update
  using (
    public.can_manage_association(association_id)
    and status = 'pending'
  );

-- Managers can list all members in associations they manage
drop policy if exists "Managers read association members" on public.association_members;
create policy "Managers read association members"
  on public.association_members for select
  using (public.can_manage_association(association_id));

-- ---------------------------------------------------------------------------
-- RPC: search profiles (username only — no email exposed)
-- ---------------------------------------------------------------------------

create or replace function public.search_profiles_for_invite(p_query text)
returns table (user_id uuid, username text)
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  q text := trim(lower(coalesce(p_query, '')));
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;
  if char_length(q) < 2 then
    return;
  end if;

  return query
  select p.id, p.username
  from public.profiles p
  where p.id <> uid
    and lower(p.username) like q || '%'
  order by p.username
  limit 20;
end;
$$;

revoke all on function public.search_profiles_for_invite(text) from public;
grant execute on function public.search_profiles_for_invite(text) to authenticated;

-- ---------------------------------------------------------------------------
-- RPC: send invite
-- ---------------------------------------------------------------------------

create or replace function public.send_association_invite(
  p_association_id uuid,
  p_invitee_user_id uuid
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  invite_id uuid;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  if not public.can_manage_association(p_association_id) then
    raise exception 'Not allowed to invite to this ledger';
  end if;

  if exists (
    select 1 from public.association_members m
    where m.association_id = p_association_id
      and m.user_id = p_invitee_user_id
  ) then
    raise exception 'User is already a member';
  end if;

  if not exists (
    select 1 from public.profiles p where p.id = p_invitee_user_id
  ) then
    raise exception 'User not found';
  end if;

  select i.id into invite_id
  from public.association_invites i
  where i.association_id = p_association_id
    and i.invitee_user_id = p_invitee_user_id
    and i.status = 'pending'
    and i.expires_at > now()
  limit 1;

  if invite_id is not null then
    return invite_id;
  end if;

  insert into public.association_invites (
    association_id,
    inviter_user_id,
    invitee_user_id,
    status,
    expires_at
  )
  values (
    p_association_id,
    uid,
    p_invitee_user_id,
    'pending',
    now() + interval '7 days'
  )
  returning id into invite_id;

  return invite_id;
end;
$$;

revoke all on function public.send_association_invite(uuid, uuid) from public;
grant execute on function public.send_association_invite(uuid, uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- RPC: respond to invite (accept / reject)
-- ---------------------------------------------------------------------------

create or replace function public.respond_association_invite(
  p_invite_id uuid,
  p_accept boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  rec record;
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  select *
  into rec
  from public.association_invites i
  where i.id = p_invite_id
    and i.invitee_user_id = uid
    and i.status = 'pending'
    and i.expires_at > now()
  for update;

  if not found then
    raise exception 'Invite not found or expired';
  end if;

  if p_accept then
    insert into public.association_members (association_id, user_id, role)
    values (rec.association_id, uid, 'member')
    on conflict (association_id, user_id) do nothing;

    update public.association_invites
    set status = 'accepted', responded_at = now()
    where id = p_invite_id;
  else
    update public.association_invites
    set status = 'rejected', responded_at = now()
    where id = p_invite_id;
  end if;
end;
$$;

revoke all on function public.respond_association_invite(uuid, boolean) from public;
grant execute on function public.respond_association_invite(uuid, boolean) to authenticated;

-- ---------------------------------------------------------------------------
-- RPC: cancel invite (manager)
-- ---------------------------------------------------------------------------

create or replace function public.cancel_association_invite(p_invite_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  update public.association_invites i
  set status = 'cancelled', responded_at = now()
  where i.id = p_invite_id
    and i.status = 'pending'
    and public.can_manage_association(i.association_id);

  if not found then
    raise exception 'Invite not found';
  end if;
end;
$$;

revoke all on function public.cancel_association_invite(uuid) from public;
grant execute on function public.cancel_association_invite(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- RPC: pending invites for current user
-- ---------------------------------------------------------------------------

create or replace function public.list_my_pending_association_invites()
returns table (
  invite_id uuid,
  association_id uuid,
  association_name text,
  inviter_username text,
  created_at timestamptz,
  expires_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    i.id,
    i.association_id,
    a.name,
    coalesce(p.username, ''),
    i.created_at,
    i.expires_at
  from public.association_invites i
  join public.associations a on a.id = i.association_id
  left join public.profiles p on p.id = i.inviter_user_id
  where i.invitee_user_id = auth.uid()
    and i.status = 'pending'
    and i.expires_at > now()
  order by i.created_at desc;
$$;

revoke all on function public.list_my_pending_association_invites() from public;
grant execute on function public.list_my_pending_association_invites() to authenticated;
