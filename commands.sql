create view dbo.fz as
    select sf.se_id as ZZ_Id,
           sf.hours_count as "Hours count",
           sf.rate as "Rate",
           (sf.hours_count * sf.rate) as "Base"
           from dbo.salary_formation as sf;

create view dbo.sum_fz as
    select sum(fz."Base") as SumBase,
           sum(fz."Hours count") as SumHours
           from dbo.fz as fz;

create view dbo.zz(id, date, sum, name) as
SELECT se.se_id                      AS id,
       se.date,
       (fzg.sum + COALESCE(bzg.sum, 0)) as total,
       comp.name
    from dbo.salary_enrollment as se
        inner join dbo.fz_grouped fzg on se.se_id = fzg.zz_id
        left outer join dbo.bz_grouped_by_se bzg on se.se_id = bzg.se_id
        inner join dbo.company comp on comp.company_id = se.company_id
    group by se.se_id, se.date, comp.name, fzg.sum, bzg.sum
    order by se.se_id;

create view dbo.bz_grouped_by_se as
    select sb.se_id, sum(sb.usd_value) from dbo.salary_bonuses as sb
group by sb.se_id
order by sb.se_id;

create view dbo.bz_grouped_by_bzt as
    select sbt.name, sum(sb.usd_value) from dbo.salary_bonuses as sb
    inner join dbo.salary_bonus_types sbt on sbt.sbt_id = sb.sbt_id
group by sb.sbt_id, sbt.name
order by sb.sbt_id;

create view dbo.fz_grouped as
    select fz.zz_id, sum(fz."Base") from dbo.fz as fz
group by fz.zz_id
order by fz.zz_id asc;

create view dbo.sum_zz as
    select sum(zz.sum) as total from dbo.zz zz;

create view dbo.taxes_view(zz_id, salary, exchange_rate, in_hrivnas, date, tax) as
SELECT ta.se_id                   AS zz_id,
       zz.sum                     AS salary,
       ta.ex_rate                 AS exchange_rate,
       zz.sum * ta.ex_rate        AS in_hrivnas,
       ta.date,
       zz.sum * ta.ex_rate * 0.05 AS tax
from dbo.taxes as ta
inner join dbo.zz zz on zz.id = ta.se_id


create view dbo.e_2020(name, month, inuah) as
SELECT ct.name,
       eh.month,
       eh.value * eh.rate AS inuah
FROM dbo.ewer_history eh
         JOIN dbo.currency_types ct ON eh.ct_id = ct.ct_id
WHERE eh.year = 2020;

create view dbo.e_2020_usd(total_usd) as
SELECT sum(eh.value) AS total_usd
FROM dbo.ewer_history eh
WHERE eh.year = 2020
  AND eh.ct_id = 1;

create view dbo.e_2020_eur(total_eur) as
SELECT sum(eh.value) AS total_eur
FROM dbo.ewer_history eh
WHERE eh.year = 2020
  AND eh.ct_id = 2;

create view dbo.e_2020_pln(total_pln) as
SELECT sum(eh.value) AS total_pln
FROM dbo.ewer_history eh
WHERE eh.year = 2020
  AND eh.ct_id = 3;

create view dbo.e_2020_uah(total_uah) as
SELECT sum(eh.value) AS total_uah
FROM dbo.ewer_history eh
WHERE eh.year = 2020
  AND eh.ct_id = 4;

create view dbo.e_2020_uah_bets(sum) as
SELECT sum(eb.value) AS sum
FROM (SELECT e.total_uah AS value
      FROM dbo.e_2020_uah e
      UNION ALL
      SELECT b.without_cashback AS value
      FROM dbo.b_2020_without_cashback b) eb;

create view dbo.b_2020(bh_id, bet, outcome, commission, bet_date, outcome_date, comment) as
SELECT bh.bh_id,
       bh.bet,
       bh.outcome,
       bh.commission,
       bh.bet_date,
       bh.outcome_date,
       bh.comment
FROM dbo.bets_history bh
WHERE bh.bet_date >= '2020-01-01'::date
  AND bh.bet_date <= '2020-12-31'::date;

create view dbo.b_2020_win_lose(win_lose) as
SELECT sum(b2020.outcome) - sum(b2020.bet) AS win_lose
FROM dbo.b_2020 b2020;

create view dbo.b_2020_cashback(cashback) as
SELECT sum(b2020.bet) * 0.03 AS cashback
FROM dbo.b_2020 b2020
WHERE b2020.bet_date > '2020-01-31'::date and (b2020.bh_id < 72 or b2020.bh_id > 97)

create view dbo.b_2020_commission(total_commission) as
SELECT sum(b2020.commission) AS total_commission
FROM dbo.b_2020 b2020;

create view dbo.b_2020_tax(tax) as
SELECT b_2020_c.cashback * 0.195 AS tax
FROM dbo.b_2020_cashback b_2020_c;

create view dbo.b_2019_clean(clean) as
SELECT bwl.win_lose + bca.cashback - bt.tax - bcm.total_commission
from dbo.b_2019_win_lose as bwl,
     dbo.b_2019_cashback as bca,
     dbo.b_2019_tax as bt,
     dbo.b_2019_commission as bcm

create view dbo.b_2020_clean(clean) as
SELECT bwl.win_lose + bca.cashback - bt.tax - bcm.total_commission
from dbo.b_2020_win_lose as bwl,
     dbo.b_2020_cashback as bca,
     dbo.b_2020_tax as bt,
     dbo.b_2020_commission as bcm;

create view dbo.b_2020_without_cashback(without_cashback) as
SELECT sum(b2020.outcome) - sum(b2020.bet) - sum(b2020.commission) AS without_cashback
FROM dbo.b_2020 b2020;

create view dbo.b_2020_debt_percent(percent) as
SELECT bcl.clean / sum(b2020.outcome) * 100
FROM dbo.b_2020 b2020, dbo.b_2020_clean bcl
group by bcl.clean;

create view dbo.b_2019_debt_percent(percent) as
SELECT bcl.clean / sum(b2019.outcome) * 100
FROM dbo.b_2019 b2019, dbo.b_2019_clean bcl
group by bcl.clean;

create table dbo.bets
(
    b_id        serial not null
        constraint bets_pk
            primary key,
    bet          numeric,
    outcome      numeric,
    commission   numeric,
    bet_date     date,
    outcome_date date,
    comment      varchar(256)
);

create view dbo.cases_view(id, usd, rate, inuah, date) as
    select c.c_id as id,
           c.usd,
           c.rate,
           (c.usd * c.rate) as inuah,
           c.date from dbo.cases c;

create view dbo.cases_total(total_usd, total_inuah, saved_usd)
as select sum(cv.usd) as total_usd,
          sum(cv.inuah) as total_inuah,
          sum(cv.usd) - cpt.payed as saved_usd
from dbo.cases_view cv, dbo.case_payouts_total cpt
group by cpt.payed;

create view dbo.case_payouts_view(id, usd, date, to_whom) as
    select cp.cp_id as id,
           cp.value_usd as usd,
           cp.date,
           cpp.name as to_whom
   from dbo.case_payouts cp inner join dbo.case_payout_people cpp on cpp.cpp_id = cp.to_whom;

create view dbo.case_payouts_by_person(name, initial, payed) as
    select cpp.name,
           cpi.value_usd as initial,
           sum(cp.value_usd) as payed
from dbo.case_payout_people cpp
    inner join dbo.case_payout_initial cpi on cpp.cpp_id = cpi.cpp_id
    inner join dbo.case_payouts cp on cpp.cpp_id = cp.to_whom
group by cpp.name, cpi.value_usd;

create view dbo.case_payouts_total(initial, payed) as
    select sum(cpbp.initial) as initial,
           sum(cpbp.payed) as payed
    from dbo.case_payouts_by_person cpbp;

create view dbo.case_payouts_left(value) as
    select cpt.initial - cpt.payed
    from dbo.case_payouts_total as cpt;

create view dbo.fund_total_by_sprint as
select fus.name,
       sum(fud.value) as sum,
       min(fud.date) as min_date,
       max(fud.date) as max_date,
       (CAST(MAX(fud.date) AS date) - CAST(MIN(fud.date) AS date)) as days,
       fus.comment
from dbo.fund_donations as fud
         inner join dbo.fund_sprints fus
             on fus.fus_id = fud.fus_id
group by fus.fus_id
order by max_date;

create view dbo.fund_first_3_sprints as
    select sum(fud.value) sum
from dbo.fund_donations fud
where fus_id in (1, 2, 5);

create view dbo.fund_on_sex_2020 as
    select sum(fuwg.value) as sum
from dbo.fund_with_girls fuwg
where cash_source = 1
and date between '2020-01-01' and '2021-01-01';

create view dbo.fund_res_2020 as
    select sum(fur.hours * fur.rate) as sum
from dbo.fund_researches fur
where date between '2020-01-01' and '2021-01-01';

create view dbo.fund_2020 as
    select (ff3s.sum - fos2020.sum - fr2020.sum) as fund
from dbo.fund_first_3_sprints as ff3s,
     dbo.fund_on_sex_2020 as fos2020,
     dbo.fund_res_2020 as fr2020;

create view dbo.fund_on_sex_2021 as
    select sum(fuwg.value) as sum
from dbo.fund_with_girls fuwg
where cash_source = 1
and date between '2021-01-01' and '2022-01-01';

create view dbo.fund_total_on_spend as
    select sum(fuwg.value) as sum
from dbo.fund_with_girls fuwg
where cash_source = 2;

create view dbo.fund_total_spends as
    select sum(fuse.value) as sum
from dbo.fund_spends fuse;

create view dbo.fund_total_researches as
    select sum(fur.hours * fur.rate) as sum
from dbo.fund_researches fur;

create view dbo.fund_total_balance as
    select (futr.sum - futs.sum - futos.sum) balance
from dbo.fund_total_researches futr, dbo.fund_total_spends futs, dbo.fund_total_on_spend futos;

create view dbo.fund_total_donations as
 select sum(fud.value) sum
from dbo.fund_donations fud;

create view dbo.fund_total_on_sex as
    select sum(fuwg.value) as sum
from dbo.fund_with_girls fuwg
where cash_source = 1;

create view dbo.fund_total as
    select (ftd.sum - futosx.sum - futr.sum) as sum
from dbo.fund_total_donations ftd, dbo.fund_total_on_sex futosx, dbo.fund_total_researches futr
