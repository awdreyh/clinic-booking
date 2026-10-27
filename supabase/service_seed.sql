-- Ensure all service categories exist, including the Membership description.
insert into public.category (name, description)
select categories.category_name, categories.description
from (values
  (
    'Signature Wellness Collection',
    'Our Signature Wellness Collection features Enso''s core therapeutic massage treatments, designed to relieve tension, restore balance, and support your overall wellbeing. Whether you seek deep muscle relief, gentle relaxation, traditional Chinese acupressure, or revitalising foot reflexology, each treatment is tailored to your individual needs for a personalised wellness experience.'
  ),
  (
    'Premium Therapy Collection',
    'Our Premium Therapy Collection offers specialised treatments that enhance the benefits of traditional massage through advanced therapeutic techniques. Featuring Hot Stone Therapy and Lymphatic Drainage Therapy, these treatments help improve circulation, encourage detoxification, ease muscular tension, and promote deep relaxation and recovery.'
  ),
  ('Membership', 'Wellness is not a luxury—it’s a lifestyle.

The Enso Annual Membership is created for those who believe that lasting health comes from consistent care. Enjoy exclusive member pricing, priority booking, and year-round wellness benefits while making self-care part of your everyday life.

At Enso, we combine professional bodywork with the philosophy of balance, mindfulness, and holistic wellbeing, creating a space where you can restore both body and mind. Your membership is an investment in a healthier, calmer, and more vibrant you.

Join Enso. Enjoy more. Live well.'),
  (
    'Package',
    'Discover a smarter way to invest in your wellbeing.\nOur pricing is designed to reward regular self-care through Annual Membership and Value Packs, helping you enjoy premium massage services at exceptional value.'
  )
) as categories(category_name, description)
where not exists (
  select 1
  from public.category existing
  where existing.name = categories.category_name
);

-- Fill these descriptions if the categories were already seeded without them.
update public.category as category
set description = seed.description
from (values
  (
    'Signature Wellness Collection',
    'Our Signature Wellness Collection features Enso''s core therapeutic massage treatments, designed to relieve tension, restore balance, and support your overall wellbeing. Whether you seek deep muscle relief, gentle relaxation, traditional Chinese acupressure, or revitalising foot reflexology, each treatment is tailored to your individual needs for a personalised wellness experience.'
  ),
  (
    'Premium Therapy Collection',
    'Our Premium Therapy Collection offers specialised treatments that enhance the benefits of traditional massage through advanced therapeutic techniques. Featuring Hot Stone Therapy and Lymphatic Drainage Therapy, these treatments help improve circulation, encourage detoxification, ease muscular tension, and promote deep relaxation and recovery.'
  )
) as seed(name, description)
where category.name = seed.name
  and (category.description is null or category.description = '');

-- Fill the description if Membership was already seeded without one.
update public.category
set description = 'Wellness is not a luxury—it’s a lifestyle.

The Enso Annual Membership is created for those who believe that lasting health comes from consistent care. Enjoy exclusive member pricing, priority booking, and year-round wellness benefits while making self-care part of your everyday life.

At Enso, we combine professional bodywork with the philosophy of balance, mindfulness, and holistic wellbeing, creating a space where you can restore both body and mind. Your membership is an investment in a healthier, calmer, and more vibrant you.

Join Enso. Enjoy more. Live well.'
where name = 'Membership'
  and (description is null or description = '');

-- Fill the Package description if that category already exists without one.
update public.category
set description = 'Discover a smarter way to invest in your wellbeing.
Our pricing is designed to reward regular self-care through Annual Membership and Value Packs, helping you enjoy premium massage services at exceptional value.'
where name = 'Package'
  and (description is null or description = '');

-- Create each service once within its category.
insert into public.service (name, category_id)
select services.service_name, category.id
from (values
  ('Signature Wellness Collection', 'Signature Wellness'),
  ('Signature Wellness Collection', 'Extra time'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage'),
  ('Premium Therapy Collection', 'Hot Stone Massage'),
  ('Premium Therapy Collection', 'extra time'),
  ('Membership', 'Annual Membership'),
  ('Package', '60-mins value pack'),
  ('Package', '30-mins value pack')
) as services(category_name, service_name)
join public.category category on category.name = services.category_name
where not exists (
  select 1
  from public.service existing
  where existing.category_id = category.id
    and existing.name = services.service_name
);

-- Import the attribute pairs from the CSV. Multiple duration/price tiers are
-- represented as separate service_attribute rows.
insert into public.service_attribute (service_id, attribute_key, attribute_value)
select service.id, attributes.attribute_key, attributes.attribute_value
from (values
  ('Signature Wellness Collection', 'SWC 30', 'duration', '30'),
  ('Signature Wellness Collection', 'SWC 30', 'price', '68'),
  ('Signature Wellness Collection', 'SWC 30', 'duration', '60'),
  ('Signature Wellness Collection', 'SWC 30', 'price', '118'),
  ('Signature Wellness Collection', 'SWC 30', 'duration', '90'),
  ('Signature Wellness Collection', 'SWC 30', 'price', '168'),
  ('Signature Wellness Collection', 'SWC 30', 'duration', '120'),
  ('Signature Wellness Collection', 'SWC 30', 'price', '218'),
  ('Signature Wellness Collection', 'extra time', 'duration', '10'),
  ('Signature Wellness Collection', 'extra time', 'price', '20'),
  ('Signature Wellness Collection', 'extra time', 'duration', '15'),
  ('Signature Wellness Collection', 'extra time', 'price', '30'),
  ('Signature Wellness Collection', 'extra time', 'duration', '20'),
  ('Signature Wellness Collection', 'extra time', 'price', '40'),
  ('Signature Wellness Collection', 'extra time', 'duration', '30'),
  ('Signature Wellness Collection', 'extra time', 'price', '60'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 'duration', '30'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 'price', '88'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 'duration', '60'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 'price', '138'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 'duration', '90'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 'price', '188'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 'duration', '120'),
  ('Premium Therapy Collection', 'Lymphatic Drainage Massage', 'price', '238'),
  ('Premium Therapy Collection', 'Hot Stone Massage', 'duration', '30'),
  ('Premium Therapy Collection', 'Hot Stone Massage', 'price', '88'),
  ('Premium Therapy Collection', 'Hot Stone Massage', 'duration', '60'),
  ('Premium Therapy Collection', 'Hot Stone Massage', 'price', '138'),
  ('Premium Therapy Collection', 'Hot Stone Massage', 'duration', '90'),
  ('Premium Therapy Collection', 'Hot Stone Massage', 'price', '188'),
  ('Premium Therapy Collection', 'Hot Stone Massage', 'duration', '120'),
  ('Premium Therapy Collection', 'Hot Stone Massage', 'price', '238'),
  ('Premium Therapy Collection', 'extra time', 'duration', '10'),
  ('Premium Therapy Collection', 'extra time', 'price', '25'),
  ('Premium Therapy Collection', 'extra time', 'duration', '15'),
  ('Premium Therapy Collection', 'extra time', 'price', '35'),
  ('Premium Therapy Collection', 'extra time', 'duration', '20'),
  ('Premium Therapy Collection', 'extra time', 'price', '45'),
  ('Premium Therapy Collection', 'extra time', 'duration', '30'),
  ('Premium Therapy Collection', 'extra time', 'price', '65'),
  ('Membership', 'Annual Membership', 'price', '200'),
  ('Package', '60-mins value pack', 'sessions', '3'),
  ('Package', '60-mins value pack', 'price', '299'),
  ('Package', '60-mins value pack', 'sessions', '5'),
  ('Package', '60-mins value pack', 'price', '480'),
  ('Package', '60-mins value pack', 'sessions', '10'),
  ('Package', '60-mins value pack', 'price', '880'),
  ('Package', '30-mins value pack', 'sessions', '3'),
  ('Package', '30-mins value pack', 'price', '180'),
  ('Package', '30-mins value pack', 'sessions', '5'),
  ('Package', '30-mins value pack', 'price', '280'),
  ('Package', '30-mins value pack', 'sessions', '10'),
  ('Package', '30-mins value pack', 'price', '500')
) as attributes(category_name, service_name, attribute_key, attribute_value)
join public.category category on category.name = attributes.category_name
join public.service service
  on service.category_id = category.id
  and service.name = attributes.service_name
where not exists (
  select 1
  from public.service_attribute existing
  where existing.service_id = service.id
    and existing.attribute_key = attributes.attribute_key
    and existing.attribute_value = attributes.attribute_value
);
