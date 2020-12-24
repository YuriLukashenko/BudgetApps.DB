--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4
-- Dumped by pg_dump version 12.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: dbo; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA dbo;


ALTER SCHEMA dbo OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cash_locations; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.cash_locations (
    cl_id integer NOT NULL,
    value numeric,
    location_name character varying(128)
);


ALTER TABLE dbo.cash_locations OWNER TO postgres;

--
-- Name: cash_locations_cl_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.cash_locations_cl_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.cash_locations_cl_id_seq OWNER TO postgres;

--
-- Name: cash_locations_cl_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.cash_locations_cl_id_seq OWNED BY dbo.cash_locations.cl_id;


--
-- Name: cash_locations_current_bets; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.cash_locations_current_bets (
    clcb_id integer NOT NULL,
    value numeric
);


ALTER TABLE dbo.cash_locations_current_bets OWNER TO postgres;

--
-- Name: cash_locations_current_bets_clcb_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.cash_locations_current_bets_clcb_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.cash_locations_current_bets_clcb_id_seq OWNER TO postgres;

--
-- Name: cash_locations_current_bets_clcb_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.cash_locations_current_bets_clcb_id_seq OWNED BY dbo.cash_locations_current_bets.clcb_id;


--
-- Name: cash_locations_mini_debts; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.cash_locations_mini_debts (
    clmd_id integer NOT NULL,
    value numeric
);


ALTER TABLE dbo.cash_locations_mini_debts OWNER TO postgres;

--
-- Name: cash_locations_mini_debts_clmd_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.cash_locations_mini_debts_clmd_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.cash_locations_mini_debts_clmd_id_seq OWNER TO postgres;

--
-- Name: cash_locations_mini_debts_clmd_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.cash_locations_mini_debts_clmd_id_seq OWNED BY dbo.cash_locations_mini_debts.clmd_id;


--
-- Name: company; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.company (
    company_id integer NOT NULL,
    name character varying(64),
    description character varying(256)
);


ALTER TABLE dbo.company OWNER TO postgres;

--
-- Name: company_companyid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.company_companyid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.company_companyid_seq OWNER TO postgres;

--
-- Name: company_companyid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.company_companyid_seq OWNED BY dbo.company.company_id;


--
-- Name: current_rate; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.current_rate (
    current_id integer NOT NULL,
    date date,
    usd numeric,
    eur numeric,
    pln numeric
);


ALTER TABLE dbo.current_rate OWNER TO postgres;

--
-- Name: current_rate_currentid_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.current_rate_currentid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.current_rate_currentid_seq OWNER TO postgres;

--
-- Name: current_rate_currentid_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.current_rate_currentid_seq OWNED BY dbo.current_rate.current_id;


--
-- Name: flux_history; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.flux_history (
    fh_id integer NOT NULL,
    ft_id integer,
    value numeric NOT NULL,
    date date,
    comment character varying(128)
);


ALTER TABLE dbo.flux_history OWNER TO postgres;

--
-- Name: flux_types; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.flux_types (
    ft_id integer NOT NULL,
    name character varying(32) NOT NULL,
    comment character varying(256)
);


ALTER TABLE dbo.flux_types OWNER TO postgres;

--
-- Name: f_2019; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.f_2019 AS
 SELECT ft.name AS type,
    fh.value,
    fh.date,
    fh.comment
   FROM (dbo.flux_history fh
     JOIN dbo.flux_types ft ON ((fh.ft_id = ft.ft_id)))
  WHERE ((fh.date >= '2019-01-01'::date) AND (fh.date <= '2019-12-31'::date));


ALTER TABLE dbo.f_2019 OWNER TO postgres;

--
-- Name: flux; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.flux (
    f_id integer NOT NULL,
    ft_id integer,
    value numeric,
    date date,
    comment character varying(256)
);


ALTER TABLE dbo.flux OWNER TO postgres;

--
-- Name: flux_f_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.flux_f_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.flux_f_id_seq OWNER TO postgres;

--
-- Name: flux_f_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.flux_f_id_seq OWNED BY dbo.flux.f_id;


--
-- Name: flux_history_fh_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.flux_history_fh_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.flux_history_fh_id_seq OWNER TO postgres;

--
-- Name: flux_history_fh_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.flux_history_fh_id_seq OWNED BY dbo.flux_history.fh_id;


--
-- Name: flux_types_ft_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.flux_types_ft_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.flux_types_ft_id_seq OWNER TO postgres;

--
-- Name: flux_types_ft_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.flux_types_ft_id_seq OWNED BY dbo.flux_types.ft_id;


--
-- Name: fop_balance; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.fop_balance (
    fop_id integer NOT NULL,
    value numeric,
    type character varying(32)
);


ALTER TABLE dbo.fop_balance OWNER TO postgres;

--
-- Name: fop_balance_fop_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.fop_balance_fop_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.fop_balance_fop_id_seq OWNER TO postgres;

--
-- Name: fop_balance_fop_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.fop_balance_fop_id_seq OWNED BY dbo.fop_balance.fop_id;


--
-- Name: salary_formation; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.salary_formation (
    sf_id integer NOT NULL,
    se_id character varying(8) NOT NULL,
    hours_count numeric NOT NULL,
    rate numeric NOT NULL
);


ALTER TABLE dbo.salary_formation OWNER TO postgres;

--
-- Name: fz; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.fz AS
 SELECT sf.se_id AS zz_id,
    sf.hours_count AS hours,
    sf.rate,
    (sf.hours_count * sf.rate) AS total
   FROM dbo.salary_formation sf;


ALTER TABLE dbo.fz OWNER TO postgres;

--
-- Name: reflux_history; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.reflux_history (
    rh_id integer NOT NULL,
    rt_id integer,
    value numeric,
    date date,
    comment character varying(256)
);


ALTER TABLE dbo.reflux_history OWNER TO postgres;

--
-- Name: reflux_types; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.reflux_types (
    rt_id integer NOT NULL,
    name character varying(32),
    comment character varying(256)
);


ALTER TABLE dbo.reflux_types OWNER TO postgres;

--
-- Name: r_2019; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.r_2019 AS
 SELECT rt.name AS type,
    rh.value,
    rh.date,
    rh.comment
   FROM (dbo.reflux_history rh
     JOIN dbo.reflux_types rt ON ((rh.rt_id = rt.rt_id)))
  WHERE ((rh.date >= '2019-01-01'::date) AND (rh.date <= '2019-12-31'::date));


ALTER TABLE dbo.r_2019 OWNER TO postgres;

--
-- Name: reflux; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.reflux (
    r_id integer NOT NULL,
    rt_id integer,
    value numeric,
    date date,
    comment character varying(256)
);


ALTER TABLE dbo.reflux OWNER TO postgres;

--
-- Name: reflux_history_rh_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.reflux_history_rh_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.reflux_history_rh_id_seq OWNER TO postgres;

--
-- Name: reflux_history_rh_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.reflux_history_rh_id_seq OWNED BY dbo.reflux_history.rh_id;


--
-- Name: reflux_r_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.reflux_r_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.reflux_r_id_seq OWNER TO postgres;

--
-- Name: reflux_r_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.reflux_r_id_seq OWNED BY dbo.reflux.r_id;


--
-- Name: reflux_types_rt_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.reflux_types_rt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.reflux_types_rt_id_seq OWNER TO postgres;

--
-- Name: reflux_types_rt_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.reflux_types_rt_id_seq OWNED BY dbo.reflux_types.rt_id;


--
-- Name: salary_converting; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.salary_converting (
    sc_id integer NOT NULL,
    usd numeric NOT NULL,
    date date,
    ex_rate numeric NOT NULL
);


ALTER TABLE dbo.salary_converting OWNER TO postgres;

--
-- Name: salary_converting_sc_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.salary_converting_sc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.salary_converting_sc_id_seq OWNER TO postgres;

--
-- Name: salary_converting_sc_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.salary_converting_sc_id_seq OWNED BY dbo.salary_converting.sc_id;


--
-- Name: salary_enrollment; Type: TABLE; Schema: dbo; Owner: postgres
--

CREATE TABLE dbo.salary_enrollment (
    se_id character varying(8) NOT NULL,
    date date,
    company_id integer
);


ALTER TABLE dbo.salary_enrollment OWNER TO postgres;

--
-- Name: salary_formation_sf_id_seq; Type: SEQUENCE; Schema: dbo; Owner: postgres
--

CREATE SEQUENCE dbo.salary_formation_sf_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dbo.salary_formation_sf_id_seq OWNER TO postgres;

--
-- Name: salary_formation_sf_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: postgres
--

ALTER SEQUENCE dbo.salary_formation_sf_id_seq OWNED BY dbo.salary_formation.sf_id;


--
-- Name: sum_actual_cash; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.sum_actual_cash AS
 SELECT sum(cl_values.value) AS sum
   FROM ( SELECT cl.value
           FROM dbo.cash_locations cl
        UNION ALL
         SELECT cl_cb.value
           FROM dbo.cash_locations_current_bets cl_cb
        UNION ALL
         SELECT cl_md.value
           FROM dbo.cash_locations_mini_debts cl_md) cl_values;


ALTER TABLE dbo.sum_actual_cash OWNER TO postgres;

--
-- Name: sum_f_2019; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.sum_f_2019 AS
 SELECT sum(f2019.value) AS sum
   FROM dbo.f_2019 f2019;


ALTER TABLE dbo.sum_f_2019 OWNER TO postgres;

--
-- Name: sum_f_2019_by_salary; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.sum_f_2019_by_salary AS
 SELECT sum(f2019.value) AS sum
   FROM dbo.f_2019 f2019
  WHERE ((f2019.type)::text = 'Зарплата'::text);


ALTER TABLE dbo.sum_f_2019_by_salary OWNER TO postgres;

--
-- Name: sum_f_2019_by_stip; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.sum_f_2019_by_stip AS
 SELECT sum(f2019.value) AS by_stip
   FROM dbo.f_2019 f2019
  WHERE ((f2019.type)::text = 'Стипендия'::text);


ALTER TABLE dbo.sum_f_2019_by_stip OWNER TO postgres;

--
-- Name: sum_fz; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.sum_fz AS
 SELECT sum(fz.hours) AS total_hours,
    avg(fz.rate) AS average_rate,
    sum(fz.total) AS total_salary
   FROM dbo.fz fz;


ALTER TABLE dbo.sum_fz OWNER TO postgres;

--
-- Name: sum_r_2019; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.sum_r_2019 AS
 SELECT sum(r2019.value) AS total
   FROM dbo.r_2019 r2019;


ALTER TABLE dbo.sum_r_2019 OWNER TO postgres;

--
-- Name: zls; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.zls AS
 SELECT sc.usd AS dollars,
    sc.date,
    sc.ex_rate AS "Exchange Rate",
    (sc.usd * sc.ex_rate) AS hrivnas
   FROM dbo.salary_converting sc;


ALTER TABLE dbo.zls OWNER TO postgres;

--
-- Name: sum_zls; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.sum_zls AS
 SELECT sum(zls.dollars) AS total_usd,
    sum(zls.hrivnas) AS total_hrivnas,
    (sum(zls.hrivnas) / sum(zls.dollars)) AS averange_ex_rate
   FROM dbo.zls zls;


ALTER TABLE dbo.sum_zls OWNER TO postgres;

--
-- Name: zz; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.zz AS
 SELECT se.se_id AS id,
    se.date,
    sum((sf.hours_count * sf.rate)) AS sum,
    comp.name
   FROM ((dbo.salary_enrollment se
     JOIN dbo.salary_formation sf ON (((se.se_id)::text = (sf.se_id)::text)))
     JOIN dbo.company comp ON ((se.company_id = comp.company_id)))
  GROUP BY se.se_id, se.date, comp.name
  ORDER BY se.se_id;


ALTER TABLE dbo.zz OWNER TO postgres;

--
-- Name: sum_zz; Type: VIEW; Schema: dbo; Owner: postgres
--

CREATE VIEW dbo.sum_zz AS
 SELECT sum(zz.sum) AS total_salazy_zz
   FROM dbo.zz zz;


ALTER TABLE dbo.sum_zz OWNER TO postgres;

--
-- Name: cash_locations cl_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.cash_locations ALTER COLUMN cl_id SET DEFAULT nextval('dbo.cash_locations_cl_id_seq'::regclass);


--
-- Name: cash_locations_current_bets clcb_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.cash_locations_current_bets ALTER COLUMN clcb_id SET DEFAULT nextval('dbo.cash_locations_current_bets_clcb_id_seq'::regclass);


--
-- Name: cash_locations_mini_debts clmd_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.cash_locations_mini_debts ALTER COLUMN clmd_id SET DEFAULT nextval('dbo.cash_locations_mini_debts_clmd_id_seq'::regclass);


--
-- Name: company company_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.company ALTER COLUMN company_id SET DEFAULT nextval('dbo.company_companyid_seq'::regclass);


--
-- Name: current_rate current_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.current_rate ALTER COLUMN current_id SET DEFAULT nextval('dbo.current_rate_currentid_seq'::regclass);


--
-- Name: flux f_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.flux ALTER COLUMN f_id SET DEFAULT nextval('dbo.flux_f_id_seq'::regclass);


--
-- Name: flux_history fh_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.flux_history ALTER COLUMN fh_id SET DEFAULT nextval('dbo.flux_history_fh_id_seq'::regclass);


--
-- Name: flux_types ft_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.flux_types ALTER COLUMN ft_id SET DEFAULT nextval('dbo.flux_types_ft_id_seq'::regclass);


--
-- Name: fop_balance fop_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.fop_balance ALTER COLUMN fop_id SET DEFAULT nextval('dbo.fop_balance_fop_id_seq'::regclass);


--
-- Name: reflux r_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.reflux ALTER COLUMN r_id SET DEFAULT nextval('dbo.reflux_r_id_seq'::regclass);


--
-- Name: reflux_history rh_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.reflux_history ALTER COLUMN rh_id SET DEFAULT nextval('dbo.reflux_history_rh_id_seq'::regclass);


--
-- Name: reflux_types rt_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.reflux_types ALTER COLUMN rt_id SET DEFAULT nextval('dbo.reflux_types_rt_id_seq'::regclass);


--
-- Name: salary_converting sc_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.salary_converting ALTER COLUMN sc_id SET DEFAULT nextval('dbo.salary_converting_sc_id_seq'::regclass);


--
-- Name: salary_formation sf_id; Type: DEFAULT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.salary_formation ALTER COLUMN sf_id SET DEFAULT nextval('dbo.salary_formation_sf_id_seq'::regclass);


--
-- Name: cash_locations_current_bets cash_locations_current_bets_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.cash_locations_current_bets
    ADD CONSTRAINT cash_locations_current_bets_pk PRIMARY KEY (clcb_id);


--
-- Name: cash_locations_mini_debts cash_locations_mini_debts_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.cash_locations_mini_debts
    ADD CONSTRAINT cash_locations_mini_debts_pk PRIMARY KEY (clmd_id);


--
-- Name: cash_locations cash_locations_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.cash_locations
    ADD CONSTRAINT cash_locations_pk PRIMARY KEY (cl_id);


--
-- Name: company company_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.company
    ADD CONSTRAINT company_pk PRIMARY KEY (company_id);


--
-- Name: current_rate current_rate_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.current_rate
    ADD CONSTRAINT current_rate_pk PRIMARY KEY (current_id);


--
-- Name: flux_history flux_history_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.flux_history
    ADD CONSTRAINT flux_history_pk PRIMARY KEY (fh_id);


--
-- Name: flux flux_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.flux
    ADD CONSTRAINT flux_pk PRIMARY KEY (f_id);


--
-- Name: flux_types flux_types_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.flux_types
    ADD CONSTRAINT flux_types_pk PRIMARY KEY (ft_id);


--
-- Name: fop_balance fop_balance_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.fop_balance
    ADD CONSTRAINT fop_balance_pk PRIMARY KEY (fop_id);


--
-- Name: reflux_history reflux_history_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.reflux_history
    ADD CONSTRAINT reflux_history_pk PRIMARY KEY (rh_id);


--
-- Name: reflux reflux_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.reflux
    ADD CONSTRAINT reflux_pk PRIMARY KEY (r_id);


--
-- Name: reflux_types reflux_types_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.reflux_types
    ADD CONSTRAINT reflux_types_pk PRIMARY KEY (rt_id);


--
-- Name: salary_enrollment salary_enrollment_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.salary_enrollment
    ADD CONSTRAINT salary_enrollment_pk PRIMARY KEY (se_id);


--
-- Name: salary_formation salary_formation_pk; Type: CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.salary_formation
    ADD CONSTRAINT salary_formation_pk PRIMARY KEY (sf_id);


--
-- Name: cash_locations_cl_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX cash_locations_cl_id_uindex ON dbo.cash_locations USING btree (cl_id);


--
-- Name: cash_locations_current_bets_clcb_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX cash_locations_current_bets_clcb_id_uindex ON dbo.cash_locations_current_bets USING btree (clcb_id);


--
-- Name: cash_locations_mini_debts_clmd_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX cash_locations_mini_debts_clmd_id_uindex ON dbo.cash_locations_mini_debts USING btree (clmd_id);


--
-- Name: company_companyid_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX company_companyid_uindex ON dbo.company USING btree (company_id);


--
-- Name: current_rate_currentid_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX current_rate_currentid_uindex ON dbo.current_rate USING btree (current_id);


--
-- Name: flux_f_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX flux_f_id_uindex ON dbo.flux USING btree (f_id);


--
-- Name: flux_history_fh_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX flux_history_fh_id_uindex ON dbo.flux_history USING btree (fh_id);


--
-- Name: flux_types_ft_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX flux_types_ft_id_uindex ON dbo.flux_types USING btree (ft_id);


--
-- Name: flux_types_name_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX flux_types_name_uindex ON dbo.flux_types USING btree (name);


--
-- Name: fop_balance_fop_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX fop_balance_fop_id_uindex ON dbo.fop_balance USING btree (fop_id);


--
-- Name: reflux_history_rh_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX reflux_history_rh_id_uindex ON dbo.reflux_history USING btree (rh_id);


--
-- Name: reflux_r_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX reflux_r_id_uindex ON dbo.reflux USING btree (r_id);


--
-- Name: reflux_types_rt_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX reflux_types_rt_id_uindex ON dbo.reflux_types USING btree (rt_id);


--
-- Name: salary_converting_sc_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX salary_converting_sc_id_uindex ON dbo.salary_converting USING btree (sc_id);


--
-- Name: salary_enrollment_se_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX salary_enrollment_se_id_uindex ON dbo.salary_enrollment USING btree (se_id);


--
-- Name: salary_formation_sf_id_uindex; Type: INDEX; Schema: dbo; Owner: postgres
--

CREATE UNIQUE INDEX salary_formation_sf_id_uindex ON dbo.salary_formation USING btree (sf_id);


--
-- Name: flux flux_flux_types_ft_id_fk; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.flux
    ADD CONSTRAINT flux_flux_types_ft_id_fk FOREIGN KEY (ft_id) REFERENCES dbo.flux_types(ft_id);


--
-- Name: flux_history flux_history_flux_types_ft_id_fk; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.flux_history
    ADD CONSTRAINT flux_history_flux_types_ft_id_fk FOREIGN KEY (ft_id) REFERENCES dbo.flux_types(ft_id);


--
-- Name: reflux_history reflux_history_reflux_types_rt_id_fk; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.reflux_history
    ADD CONSTRAINT reflux_history_reflux_types_rt_id_fk FOREIGN KEY (rt_id) REFERENCES dbo.reflux_types(rt_id);


--
-- Name: reflux reflux_reflux_types_rt_id_fk; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.reflux
    ADD CONSTRAINT reflux_reflux_types_rt_id_fk FOREIGN KEY (rt_id) REFERENCES dbo.reflux_types(rt_id);


--
-- Name: salary_enrollment salary_enrollment_company_id_fk; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.salary_enrollment
    ADD CONSTRAINT salary_enrollment_company_id_fk FOREIGN KEY (company_id) REFERENCES dbo.company(company_id);


--
-- Name: salary_formation salary_formation_salary_enrollment_se_id_fk; Type: FK CONSTRAINT; Schema: dbo; Owner: postgres
--

ALTER TABLE ONLY dbo.salary_formation
    ADD CONSTRAINT salary_formation_salary_enrollment_se_id_fk FOREIGN KEY (se_id) REFERENCES dbo.salary_enrollment(se_id);


--
-- PostgreSQL database dump complete
--

