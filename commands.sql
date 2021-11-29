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
from dbo.fund_total_donations ftd, dbo.fund_total_on_sex futosx, dbo.fund_total_researches futr;

create view dbo.e_2021(name, month, inuah) as
SELECT ct.name,
       eh.month,
       eh.value * eh.rate AS inuah
FROM dbo.ewer_history eh
         JOIN dbo.ewer_currency_types ct ON eh.ect_id = ct.ect_id
WHERE eh.year = 2021;

create view dbo.e_2021_usd(total_usd) as
SELECT sum(eh.value) AS total_usd
FROM dbo.ewer_history eh
WHERE eh.year = 2021
  AND eh.ect_id = 1;

create view dbo.e_2021_eur(total_eur) as
SELECT sum(eh.value) AS total_eur
FROM dbo.ewer_history eh
WHERE eh.year = 2021
  AND eh.ect_id = 2;

create view dbo.e_2021_pln(total_pln) as
SELECT sum(eh.value) AS total_pln
FROM dbo.ewer_history eh
WHERE eh.year = 2021
  AND eh.ect_id = 3;

create view dbo.e_2021_uah(total_uah) as
SELECT sum(eh.value) AS total_uah
FROM dbo.ewer_history eh
WHERE eh.year = 2021
  AND eh.ect_id = 4;

create view dbo.current_cash_flux_2021(sum) as
SELECT sum(f.value) AS sum
FROM dbo.flux f;

create view dbo.current_cash_reflux_2021(sum) as
SELECT sum(r.value) AS sum
FROM dbo.reflux r;

create view dbo.current_cash_donation_2021_with_incorrect(sum) as
select sum(fud.value) sum
from dbo.fund_donations fud
where fud.date between '2021-01-01' and '2022-01-01'
or fud.fus_id = 7;

create view dbo.current_cash_credit_2021(sum) as
    select sum(cr.value) sum
from dbo.credit cr
where start_date >= '2021-01-01' and end_date is null;

create view dbo.current_cash_case_2021(sum) as
    select sum(cv.inuah) as sum
from dbo.cases_view cv
where cv.date between '2021-01-01' and '2022-01-01';

create view dbo.current_cash_ewer_2021(sum) as
    select sum(e.inuah) as sum
from dbo.e_2021 e;

create view dbo.current_cash(total) as
    select (f.sum - r.sum - e.sum - c.sum - cr.sum - ftwi.sum) as total
from dbo.current_cash_flux_2021 f,
     dbo.current_cash_reflux_2021 r,
     dbo.current_cash_ewer_2021 e,
     dbo.current_cash_case_2021 c,
     dbo.current_cash_credit_2021 cr,
     dbo.current_cash_donation_2021_with_incorrect ftwi;

create view dbo.salary_bz_grouped_by_se as
    select se.se_id,
           se.date,
           sum(sb.usd_value) as sum
from dbo.salary_bonuses sb
    inner join dbo.salary_enrollment se on sb.se_id = se.se_id
group by se.se_id
order by se.se_id;

create view dbo.salary_bz_grouped_by_sbt as
    select sbt.name,
           sum(sb.usd_value) as sum
from dbo.salary_bonuses sb
    inner join dbo.salary_bonus_types sbt on sbt.sbt_id = sb.sbt_id
group by sbt.sbt_id
order by sum;

create view dbo.common_ewer_spend_2020 as
    select es.date,
           ect.name,
           es.value,
           (es.value * es.rate) inuah,
           es.comment
from dbo.ewer_spend es
    inner join dbo.ewer_currency_types ect on ect.ect_id = es.ect_id
where es.date between '2020-01-01' and '2021-01-01'
order by date;

create view dbo.common_ewer_spend_2021 as
    select es.date,
           ect.name,
           es.value,
           (es.value * es.rate) inuah,
           es.comment
from dbo.ewer_spend es
    inner join dbo.ewer_currency_types ect on ect.ect_id = es.ect_id
where es.date between '2021-01-01' and '2022-01-01'
order by date;

create view dbo.common_ewer_spend_usd as
    select sum(es.value) sum
from dbo.ewer_spend es
where ect_id = 1
group by es.ect_id;

create view dbo.common_ewer_spend_eur as
    select sum(es.value) sum
from dbo.ewer_spend es
where ect_id = 2
group by es.ect_id;

create view dbo.common_ewer_spend_pln as
    select sum(es.value) sum
from dbo.ewer_spend es
where ect_id = 3
group by es.ect_id;

create view dbo.common_ewer_spend_uah as
    select sum(es.value) sum
from dbo.ewer_spend es
where ect_id = 4
group by es.ect_id;

create view dbo.ewer_2019(name, month, inuah) as
SELECT ct.name,
       e.month,
       e.value * e.rate AS inuah
FROM dbo.ewer e
         JOIN dbo.ewer_currency_types ct ON e.ect_id = ct.ect_id
WHERE e.year = 2019;

create view dbo.ewer_2019_sum(sum) as
SELECT sum(e2019.inuah) AS sum
FROM dbo.ewer_2019 e2019;

create view dbo.ewer_2019_remain(sum) as
    select (f.sum - r.total - e.sum) as sum
from dbo.sum_2019_flux f, dbo.sum_2019_reflux r, dbo.ewer_2019_sum e;

create view dbo.ewer_2019_total_invest_by_month(m, total_invest_by_month, year) as
SELECT e2019.month      AS m,
       sum(e2019.inuah) AS total_invest_by_month,
       2019             AS year
FROM dbo.ewer_2019 e2019
GROUP BY m
ORDER BY m;

create view dbo.ewer_2019_eur(total_eur) as
SELECT sum(e.value) AS total_eur
FROM dbo.ewer e
WHERE e.year = 2019
  AND e.ect_id = 2;

create view dbo.ewer_2019_pln(total_pln) as
SELECT sum(e.value) AS total_pln
FROM dbo.ewer e
WHERE e.year = 2019
  AND e.ect_id = 3;

create view dbo.ewer_2019_uah(total_uah) as
SELECT sum(e.value) AS total_uah
FROM dbo.ewer e
WHERE e.year = 2019
  AND e.ect_id = 4;

create view dbo.ewer_2019_uah_bets(sum) as
SELECT sum(eb.value) AS sum
FROM (SELECT e.total_uah AS value
      FROM dbo.ewer_2019_uah e
      UNION ALL
      SELECT b.without_cashback AS value
      FROM dbo.b_2019_without_cashback b) eb;

create view dbo.ewer_2019_usd(total_usd) as
SELECT sum(e.value) AS total_usd
FROM dbo.ewer e
WHERE e.year = 2019
  AND e.ect_id = 1;

create view dbo.ewer_2020(name, month, inuah) as
SELECT ct.name,
       e.month,
       e.value * e.rate AS inuah
FROM dbo.ewer e
         JOIN dbo.ewer_currency_types ct ON e.ect_id = ct.ect_id
WHERE e.year = 2020;

create view dbo.ewer_2020_eur(total_eur) as
SELECT sum(e.value) AS total_eur
FROM dbo.ewer e
WHERE e.year = 2020
  AND e.ect_id = 2;

create view dbo.ewer_2020_pln(total_pln) as
SELECT sum(e.value) AS total_pln
FROM dbo.ewer e
WHERE e.year = 2020
  AND e.ect_id = 3;

create view dbo.ewer_2020_uah(total_uah) as
SELECT sum(e.value) AS total_uah
FROM dbo.ewer e
WHERE e.year = 2020
  AND e.ect_id = 4;

create view dbo.ewer_2020_uah_bets(sum) as
SELECT sum(eb.value) AS sum
FROM (SELECT e.total_uah AS value
      FROM dbo.ewer_2020_uah e
      UNION ALL
      SELECT b.without_cashback AS value
      FROM dbo.b_2020_without_cashback b) eb;

create view dbo.ewer_2020_usd(total_usd) as
SELECT sum(e.value) AS total_usd
FROM dbo.ewer e
WHERE e.year = 2020
  AND e.ect_id = 1;

create view dbo.ewer_2020_sum(sum) as
SELECT sum(e2020.inuah) AS sum
FROM dbo.ewer_2020 e2020;

create view dbo.ewer_2020_total_invest_by_month(m, total_invest_by_month, year) as
SELECT e2020.month      AS m,
       sum(e2020.inuah) AS total_invest_by_month,
       2020             AS year
FROM dbo.ewer_2020 e2020
GROUP BY m
ORDER BY m;

create view dbo.ewer_2021(name, month, inuah) as
SELECT ct.name,
       e.month,
       e.value * e.rate AS inuah
FROM dbo.ewer e
         JOIN dbo.ewer_currency_types ct ON e.ect_id = ct.ect_id
WHERE e.year = 2021;

create view dbo.ewer_2021_eur(total_eur) as
SELECT sum(e.value) AS total_eur
FROM dbo.ewer e
WHERE e.year = 2021
  AND e.ect_id = 2;

create view dbo.ewer_2021_pln(total_pln) as
SELECT sum(e.value) AS total_pln
FROM dbo.ewer e
WHERE e.year = 2021
  AND e.ect_id = 3;

create view dbo.ewer_2021_uah(total_uah) as
SELECT sum(e.value) AS total_uah
FROM dbo.ewer e
WHERE e.year = 2021
  AND e.ect_id = 4;

create view dbo.ewer_2021_uah_bets(sum) as
SELECT (e.total_uah - 1584) AS sum
from dbo.ewer_2021_uah e;

create view dbo.ewer_2021_usd(total_usd) as
SELECT sum(e.value) AS total_usd
FROM dbo.ewer e
WHERE e.year = 2021
  AND e.ect_id = 1;

create view dbo.ewer_2021_sum(sum) as
SELECT sum(e2021.inuah) AS sum
FROM dbo.ewer_2021 e2021;

create view dbo.ewer_2021_total_invest_by_month(m, total_invest_by_month, year) as
SELECT e2021.month      AS m,
       sum(e2021.inuah) AS total_invest_by_month,
       2021             AS year
FROM dbo.ewer_2021 e2021
GROUP BY m
ORDER BY m;

create view dbo.current_cash_ewer_2021(sum) as
SELECT sum(e.inuah) AS sum
FROM dbo.ewer_2021 e;

create view dbo.current_cash(total) as
SELECT f.sum - r.sum - e.sum - c.sum - cr.sum - ftwi.sum::numeric AS total
FROM dbo.current_cash_flux_2021 f,
     dbo.current_cash_reflux_2021 r,
     dbo.current_cash_ewer_2021 e,
     dbo.current_cash_case_2021 c,
     dbo.current_cash_credit_2021 cr,
     dbo.current_cash_donation_2021_with_incorrect ftwi;

create view dbo.ewer_eur(total_eur) as
SELECT sum(e.value) AS total_eur
FROM dbo.ewer e
WHERE e.ect_id = 2;

create view dbo.ewer_pln(total_pln) as
SELECT sum(e.value) AS total_pln
FROM dbo.ewer e
WHERE e.ect_id = 3;

create view dbo.ewer_uah(total_uah) as
SELECT sum(e.value) AS total_uah
FROM dbo.ewer e
WHERE e.ect_id = 4;

create view dbo.ewer_usd(total_usd) as
SELECT sum(e.value) AS total_usd
FROM dbo.ewer e
WHERE e.ect_id = 1;

create view dbo.common_ewer_credit_eur(total_eur) as
SELECT sum(ec.value) AS total_eur
FROM dbo.ewer_credit ec
WHERE ec.ect_id = 2;

create view dbo.common_ewer_credit_pln(total_pln) as
SELECT sum(ec.value) AS total_pln
FROM dbo.ewer_credit ec
WHERE ec.ect_id = 3;

create view dbo.common_ewer_credit_uah(total_uah) as
SELECT sum(ec.value) AS total_uah
FROM dbo.ewer_credit ec
WHERE ec.ect_id = 4;

create view dbo.common_ewer_credit_usd(total_usd) as
SELECT sum(ec.value) AS total_usd
FROM dbo.ewer_credit ec
WHERE ec.ect_id = 1;


create view dbo.common_ewer_eur(total_eur) as
select (ee.total_eur -  cese.sum - cece.total_eur) as total_eur
from dbo.ewer_eur ee, dbo.common_ewer_spend_eur cese, dbo.common_ewer_credit_eur cece;

create view dbo.common_ewer_pln(total_pln) as
select (ep.total_pln -  cesp.sum - cecp.total_pln) as total_pln
from dbo.ewer_pln ep, dbo.common_ewer_spend_pln cesp, dbo.common_ewer_credit_pln cecp;

create view dbo.common_ewer_uah(total_uah) as
select (eu.total_uah -  cesu.sum - cecu.total_uah) as total_uah
from dbo.ewer_uah eu, dbo.common_ewer_spend_uah cesu, dbo.common_ewer_credit_uah cecu;

create view dbo.common_ewer_uah_with_bets(total_uah) as
select (e2019ub.sum + e2020ub.sum + e2021ub.sum -  cesu.sum - cecu.total_uah) as total_uah
from dbo.ewer_2019_uah_bets e2019ub,
     dbo.ewer_2020_uah_bets e2020ub,
     dbo.ewer_2021_uah_bets e2021ub,
     dbo.common_ewer_spend_uah cesu,
     dbo.common_ewer_credit_uah cecu;

create view dbo.common_ewer_usd(total_usd) as
select (eusd.total_usd -  cesusd.sum - cecusd.total_usd) as total_usd
from dbo.ewer_usd eusd, dbo.common_ewer_spend_usd cesusd, dbo.common_ewer_credit_usd cecusd;

create view dbo.common_ewer_inuah as
    select (cee.total_eur * cr.eur) as total_eur,
           (cep.total_pln * cr.pln) as total_pln,
           (ceuwb.total_uah) as total_uah,
           (ceu.total_usd * cr.usd) as total_usd
from dbo.common_ewer_eur as cee,
     dbo.common_ewer_pln as cep,
     dbo.common_ewer_uah_with_bets as ceuwb,
     dbo.common_ewer_usd as ceu,
     dbo.current_rate as cr
order by cr.current_id desc
limit 1;

create view dbo.common_ewer_inuah_up_to_date as
select (cei.total_eur + cei.total_pln + cei.total_uah + cei.total_usd) as total_inuah
from dbo.common_ewer_inuah cei;

create view dbo.open_credits as
select sum(value) as sum
from dbo.credit
where end_date is null;

create view dbo.total_values_uah as
    select (cc.total + ft.sum + ftb.balance + cr.sum + ceuwb.total_uah + cecu.total_uah) as sum
from dbo.current_cash as cc,
     dbo.fund_total as ft,
     dbo.fund_total_balance as ftb,
     dbo.open_credits as cr,
     dbo.common_ewer_uah_with_bets as ceuwb,
     dbo.common_ewer_credit_uah as cecu
	 
create view dbo.bets_2019(b_id, bet, outcome, commission, bet_date, outcome_date, comment) as
SELECT b.b_id,
       b.bet,
       b.outcome,
       b.commission,
       b.bet_date,
       b.outcome_date,
       b.comment
FROM dbo.bets b
WHERE b.bet_date >= '2019-01-01'::date
  AND b.bet_date <= '2019-12-31'::date;

create view dbo.bets_2019_win_lose(win_lose) as
SELECT sum(b2019.outcome) - sum(b2019.bet) AS win_lose
FROM dbo.bets_2019 b2019;

create view dbo.bets_2019_cashback(cashback) as
SELECT sum(b2019.bet) * 0.03 AS cashback
FROM dbo.bets_2019 b2019
WHERE b2019.bet_date > '2019-04-30'::date;

create view dbo.bets_2019_tax(tax) as
SELECT b_2019_c.cashback * 0.195 AS tax
FROM dbo.bets_2019_cashback b_2019_c;

create view dbo.bets_2019_commission(total_commission) as
SELECT sum(b2019.commission) AS total_commission
FROM dbo.bets_2019 b2019;

create view dbo.bets_2019_clean(clean) as
SELECT bwl.win_lose + bca.cashback - bt.tax - bcm.total_commission AS clean
FROM dbo.bets_2019_win_lose bwl,
     dbo.bets_2019_cashback bca,
     dbo.bets_2019_tax bt,
     dbo.bets_2019_commission bcm;

create view dbo.bets_2019_without_cashback(without_cashback) as
SELECT sum(b2019.outcome) - sum(b2019.bet) - sum(b2019.commission) AS without_cashback
FROM dbo.bets_2019 b2019;

create view dbo.bets_2019_debt_percent(percent) as
SELECT bcl.clean / sum(b2019.outcome) * 100::numeric AS percent
FROM dbo.bets_2019 b2019,
     dbo.bets_2019_clean bcl
GROUP BY bcl.clean;

create view dbo.bets_2019_sum_bets(total_bets) as
SELECT sum(b2019.bet) AS total_bets
FROM dbo.bets_2019 b2019;

create view dbo.common_ewer_inuah(total_eur, total_pln, total_uah, total_usd) as
SELECT cee.total_eur * cr.eur AS total_eur,
       cep.total_pln * cr.pln AS total_pln,
       ceua.total_uah,
       ceu.total_usd * cr.usd AS total_usd
FROM dbo.common_ewer_eur cee,
     dbo.common_ewer_pln cep,
     dbo.common_ewer_uah ceua,
     dbo.common_ewer_usd ceu,
     dbo.current_rate cr
ORDER BY cr.current_id DESC
LIMIT 1;

create view dbo.common_ewer_inuah_up_to_date(total_inuah) as
SELECT cei.total_eur + cei.total_pln + cei.total_uah + cei.total_usd AS total_inuah
FROM dbo.common_ewer_inuah cei;

create view dbo.total_values_uah(sum) as
SELECT cc.total + ft.sum + ftb.balance + cr.sum + ceu.total_uah + cecu.total_uah AS sum
FROM dbo.current_cash cc,
     dbo.fund_total ft,
     dbo.fund_total_balance ftb,
     dbo.open_credits cr,
     dbo.common_ewer_uah ceu,
     dbo.common_ewer_credit_uah cecu;

create view dbo.bets_2020(b_id, bet, outcome, commission, bet_date, outcome_date, comment) as
SELECT b.b_id,
       b.bet,
       b.outcome,
       b.commission,
       b.bet_date,
       b.outcome_date,
       b.comment
FROM dbo.bets b
WHERE b.bet_date >= '2020-01-01'::date
  AND b.bet_date <= '2020-12-31'::date;

create view dbo.bets_2020_sum_bets(total_bets) as
SELECT sum(b2020.bet) AS total_bets
FROM dbo.bets_2020 b2020;

create view dbo.bets_2020_without_cashback(without_cashback) as
SELECT sum(b2020.outcome) - sum(b2020.bet) - sum(b2020.commission) AS without_cashback
FROM dbo.bets_2020 b2020;

create view dbo.bets_2020_win_lose(win_lose) as
SELECT sum(b2020.outcome) - sum(b2020.bet) AS win_lose
FROM dbo.bets_2020 b2020;

create view dbo.bets_2020_commission(total_commission) as
SELECT sum(b2020.commission) AS total_commission
FROM dbo.bets_2020 b2020;

create view dbo.bets_2020_cashback(cashback) as
SELECT sum(b2020.bet) * 0.03 AS cashback
FROM dbo.bets_2020 b2020
WHERE b2020.bet_date > '2020-01-31'::date
  AND (b2020.b_id < 72 OR b2020.b_id > 97);

create view dbo.bets_2020_tax(tax) as
SELECT b_2020_c.cashback * 0.195 AS tax
FROM dbo.bets_2020_cashback b_2020_c;

create view dbo.bets_2020_clean(clean) as
SELECT bwl.win_lose + bca.cashback - bt.tax - bcm.total_commission AS clean
FROM dbo.bets_2020_win_lose bwl,
     dbo.bets_2020_cashback bca,
     dbo.bets_2020_tax bt,
     dbo.bets_2020_commission bcm;

create view dbo.bets_2020_debt_percent(percent) as
SELECT bcl.clean / sum(b2020.outcome) * 100::numeric AS percent
FROM dbo.bets_2020 b2020,
     dbo.bets_2020_clean bcl
GROUP BY bcl.clean;

create view dbo.bets_2021(b_id, bet, outcome, commission, bet_date, outcome_date, comment) as
SELECT b.b_id,
       b.bet,
       b.outcome,
       b.commission,
       b.bet_date,
       b.outcome_date,
       b.comment
FROM dbo.bets b
WHERE b.bet_date >= '2021-01-01'::date
  AND b.bet_date <= '2021-12-31'::date;

create view dbo.bets_2021_sum_bets(total_bets) as
SELECT sum(b2021.bet) AS total_bets
FROM dbo.bets_2021 b2021;

create view dbo.bets_2021_without_cashback(without_cashback) as
SELECT sum(b2021.outcome) - sum(b2021.bet) - sum(b2021.commission) AS without_cashback
FROM dbo.bets_2021 b2021;

create view dbo.bets_2021_win_lose(win_lose) as
SELECT sum(b2021.outcome) - sum(b2021.bet) AS win_lose
FROM dbo.bets_2021 b2021;

create view dbo.bets_2021_commission(total_commission) as
SELECT sum(b2021.commission) AS total_commission
FROM dbo.bets_2021 b2021;

create view dbo.bets_2021_cashback(cashback) as
SELECT sum(b2021.bet) * 0.03 AS cashback
FROM dbo.bets_2021 b2021
WHERE b2021.b_id > 186 AND b2021.b_id < 220;

create view dbo.bets_2021_tax(tax) as
SELECT b_2021_c.cashback * 0.195 AS tax
FROM dbo.bets_2021_cashback b_2021_c;

create view dbo.bets_2021_clean(clean) as
SELECT bwl.win_lose + bca.cashback - bt.tax - bcm.total_commission AS clean
FROM dbo.bets_2021_win_lose bwl,
     dbo.bets_2021_cashback bca,
     dbo.bets_2021_tax bt,
     dbo.bets_2021_commission bcm;

create view dbo.bets_2021_debt_percent(percent) as
SELECT bcl.clean / sum(b2021.outcome) * 100::numeric AS percent
FROM dbo.bets_2021 b2021,
     dbo.bets_2021_clean bcl
GROUP BY bcl.clean;