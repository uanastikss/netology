
------------------Fact_Flights – таблица фактов:------------------
CREATE TABLE public.fact_flights (
 	PRIMARY KEY (passenger_id_fk, actual_departure, departure_airport_fk),
	passenger_id_fk int4 NULL,
	actual_departure timestamp NULL,
	actual_arrival timestamp NULL,
	departure_delay float8 NULL,
	arrival_delay float8 NULL,
	aircraft_code_fk int4 NULL,
	departure_airport_fk int4 NULL,
	arrival_airport_fk int4 NULL,
	fare_conditions_fk int4 NULL,
	amount numeric(12,2) NULL,
	actual_departure_date_fk int4 NULL,
	actual_arrival_date_fk int4 NULL,
	CONSTRAINT aircraft_fk FOREIGN KEY (aircraft_code_fk) REFERENCES public.dim_aircrafts(id),
	CONSTRAINT arrival_airport_fk FOREIGN KEY (arrival_airport_fk) REFERENCES public.dim_airports(id),
	CONSTRAINT arrival_date_fk FOREIGN KEY (actual_arrival_date_fk) REFERENCES public.dim_calendar(id),
	CONSTRAINT departure_airport_fk FOREIGN KEY (departure_airport_fk) REFERENCES public.dim_airports(id),
	CONSTRAINT departure_date_fk FOREIGN KEY (actual_departure_date_fk) REFERENCES public.dim_calendar(id),
	CONSTRAINT fare_conditions_fk FOREIGN KEY (fare_conditions_fk) REFERENCES public.dim_tariff(id),
	CONSTRAINT passenger_fk FOREIGN KEY (passenger_id_fk) REFERENCES public.dim_passengers(id)
);

-----------------------------------------------------------------------------------SQL скрипты справочников:-----------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------
--                                    СОЗДАНИЕ КАЛЕНДАРЯ                                    --
-- -------------------------------------------------------------------------------------------
-- К сожалению, через запрос вида (SELECT MIN(scheduled_departure) FROM demo.bookings.flights)
-- сделать нельзя, т.к. итоговая работа выполняется в БД dwh_result. Поэтому вводим результаты
-- таких запросов руками:
-- -------------------------------------------------------------------------------------------

CREATE TABLE public.dim_calendar (
	id serial NOT NULL,
	calendar_date date NULL,
	CONSTRAINT dim_calendar_pkey PRIMARY KEY (id)
);


insert into dim_calendar(calendar_date)
select generate_series(to_date('13.09.2016','dd.mm.yyyy'),to_date('12.11.2016','dd.mm.yyyy'),'1 day');


---------------Dim_Passengers - справочник пассажиров: -----------------------------
CREATE TABLE public.dim_passengers (
	id serial NOT NULL,
	passenger_id varchar(20) NOT NULL,
	passenger_name text NOT NULL,
	contact_data varchar(400) NULL,
	CONSTRAINT dim_passengers_pkey PRIMARY KEY (id)
);

---------------Dim_Airports - справочник самолетов: -----------------------------
CREATE TABLE public.dim_airports (
	id serial NOT NULL,
	airport_code bpchar(3) NOT NULL,
	airport_name text NOT NULL,
	city text NOT NULL,
	longitude float8 NOT NULL,
	latitude float8 NOT NULL,
	timezone text NOT NULL,
	CONSTRAINT dim_airports_pkey PRIMARY KEY (id)
);

---------------Dim_Aircrafts - справочник аэропортов: -----------------------------
CREATE TABLE public.dim_aircrafts (
	id serial NOT NULL,
	aircraft_code bpchar(3) NOT NULL,
	model text NOT NULL,
	"range" int4 NOT NULL,
	CONSTRAINT aircrafts_range_check CHECK ((range > 0)),
	CONSTRAINT dim_aircrafts_pkey PRIMARY KEY (id)
);


---------------Dim_Tariff - справочник тарифов (Эконом/бизнес и тд): -----------------------------

CREATE TABLE public.dim_tariff (
	id serial NOT NULL,
	fare_conditions varchar(10) NOT NULL,
	CONSTRAINT dim_tariff_pkey PRIMARY KEY (id),
	CONSTRAINT seats_fare_conditions_check CHECK (((fare_conditions)::text = ANY (ARRAY[('Economy'::character varying)::text, ('Comfort'::character varying)::text, ('Business'::character varying)::text]))),
	CONSTRAINT unique_conditions UNIQUE (fare_conditions)
);



-----------------------------------------------------------------------------------SQL скрипты rejected-таблиц:-----------------------------------------------------------------------------------------

---------------fact_flights_problem: -----------------------------

CREATE TABLE public.fact_flights_problem (
	id serial NOT NULL,
	passenger_id varchar(64) NULL,
	actual_departure timestamp NULL,
	actual_arrival timestamp NULL,
	actual_departure_date timestamp NULL,
	actual_arrival_date timestamp NULL,
	departure_delay float8 NULL,
	arrival_delay float8 NULL,
	aircraft_code varchar(3) NULL,
	departure_airport varchar(64) NULL,
	arrival_airport varchar(64) NULL,
	fare_conditions varchar(64) NULL,
	amount numeric(12,2) NULL,
	passenger_id_fk int4 NULL,
	problem varchar(400) NULL,
	CONSTRAINT fact_flights_problem_pkey PRIMARY KEY (id)
);

---------------passengers_problem:-----------------------------
CREATE TABLE public.passengers_problem (
	id serial NOT NULL,
	passenger_id text NULL,
	passenger_name text NULL,
	contact_data text NULL,
	book_date text NULL,
	problem varchar(400) NULL,
	CONSTRAINT passengers_problem_pkey PRIMARY KEY (id)
);

---------------aircrafts_problem:-----------------------------
CREATE TABLE public.aircrafts_problem (
	id serial NOT NULL,
	aircraft_code varchar(15) NULL,
	model text NULL,
	"range" int4 NULL,
	problem varchar(400) NULL,
	CONSTRAINT aircrafts_problem_pkey PRIMARY KEY (id)
);

---------------airports_problem:-----------------------------
CREATE TABLE public.airports_problem (
	id serial NOT NULL,
	airport_code text NULL,
	airport_name text NULL,
	city text NULL,
	longitude float8 NULL,
	latitude float8 NULL,
	timezone text NULL,
	problem varchar(400) NULL,
	CONSTRAINT airports_problem_pkey PRIMARY KEY (id)
);

---------------tarif_problem:-----------------------------
CREATE TABLE public.tarif_problem (
	id serial NOT NULL,
	fare_conditions varchar(64) NULL,
	problem varchar(400) NULL,
	CONSTRAINT tarif_problem_pkey PRIMARY KEY (id)
);




