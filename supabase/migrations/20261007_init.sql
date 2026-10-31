create type public.user_role as enum ('customer', 'therapist', 'admin');

create table public.user (
 id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text,
  phone text unique,
  description text,
  is_active boolean default true,
  is_member boolean default false,
  last_login timestamp with time zone,
  updated_at timestamp with time zone,
  member_since timestamp with time zone,
  membership_expires timestamp with time zone,
  profile_picture text,
  photo text,
  meta jsonb,
  address text,
  role public.user_role not null default 'customer',
  created_at timestamp with time zone default now()
);

-- Populate public."user" whenever a new auth.users row is created.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public."user" (id, name, email, phone, role)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data->>'name', ''), nullif(split_part(coalesce(new.email, ''), '@', 1), ''), new.id::text),
    new.email,
    nullif(new.raw_user_meta_data->>'phone', ''),
    'customer'::public.user_role
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


create table public.rules (
  id bigint generated always as identity primary key,
  day_of_week smallint not null unique check (day_of_week between 0 and 6),
  start_time time not null default '09:00',
  end_time time not null default '21:00',
  slot_duration integer not null default 30 check (slot_duration > 0),
  created_at timestamp with time zone default now(),
  check (start_time < end_time)
);

insert into public.rules (day_of_week, start_time, end_time, slot_duration)
select day_of_week, '09:00', '21:00', 30 from generate_series(0, 6) as day_of_week;


create table public.category (
  id bigint generated always as identity primary key,
  name text not null,
  description text,
  image text,
  parent_id bigint references public.category(id) on delete cascade,
  created_at timestamp with time zone default now()
);

create table public.service (
  id bigint generated always as identity primary key,
  name text not null,
  description text,
  image text,
  category_id bigint references public.category(id) on delete cascade,  
  created_at timestamp with time zone default now()
);


create table public.service_attribute (
  id bigint generated always as identity primary key,
  service_id bigint not null references public.service(id) on delete cascade,
  duration integer,
  sessions integer,
  price numeric(10,2) not null,
  created_at timestamp with time zone default now(),
  check (duration is null or sessions is null),
  unique (service_id, duration),
  unique (service_id, sessions)
);

create table public.service_therapist (
  id bigint generated always as identity primary key,
  therapist_id uuid references public.user(id) on delete cascade,
  service_id bigint references public.service(id) on delete cascade,
  created_at timestamp with time zone default now()
);

create table public.booking (
  id bigint generated always as identity primary key,
  customer_id uuid references public.user(id) on delete cascade,
  booking_date date not null,
  start_time time not null,
  end_time time not null,
  status text check (status in ('booked','pending', 'cancelled')) default 'pending',
  therapist_id uuid references public.user(id) on delete cascade,
  service_id bigint,
  duration interval,
  price numeric(10,2),
  notes text,
  created_at timestamp with time zone default now()
);

create unique index booking_active_therapist_slot_unique
  on public.booking (therapist_id, booking_date, start_time)
  where status in ('booked', 'pending');
