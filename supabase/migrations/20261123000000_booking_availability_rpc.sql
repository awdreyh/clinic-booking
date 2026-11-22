-- Let authenticated customers see occupied time intervals without exposing
-- another customer's booking details or bypassing booking table RLS.
create or replace function public.get_busy_booking_times(
  p_booking_date date,
  p_therapist_ids uuid[] default null
)
returns table (
  therapist_id uuid,
  start_time time,
  end_time time
)
language sql
security definer
set search_path = ''
stable
as $$
  select b.therapist_id, b.start_time, b.end_time
  from public.booking as b
  where b.booking_date = p_booking_date
    and b.status in ('booked', 'pending')
    and b.therapist_id is not null
    and (p_therapist_ids is null or b.therapist_id = any(p_therapist_ids));
$$;

revoke all on function public.get_busy_booking_times(date, uuid[]) from public;
grant execute on function public.get_busy_booking_times(date, uuid[]) to authenticated;
