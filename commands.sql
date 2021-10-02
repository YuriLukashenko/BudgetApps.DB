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