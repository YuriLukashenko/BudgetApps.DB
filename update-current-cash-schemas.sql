create view dbo.current_cash(total) as
SELECT f.sum - r.sum - e.sum - c.sum - cr.sum - d.sum::numeric + b.sum - a.sum - de.sum AS total
FROM dbo.current_cash_2022_flux f,
     dbo.current_cash_2022_reflux r,
     dbo.current_cash_2022_ewer e,
     dbo.current_cash_2022_case c,
     dbo.current_cash_2022_credit cr,
     dbo.current_cash_2022_donation d,
     dbo.current_cash_2022_bets b,
     dbo.current_cash_2022_army a,
     dbo.current_cash_2022_deposit de;

create view dbo.total_values_uah(sum) as
SELECT cc.total + ft.sum + ftb.balance + cr.sum + ceu.total_uah + cecu.total_uah AS sum
FROM dbo.current_cash cc,
     dbo.fund_total ft,
     dbo.fund_total_balance ftb,
     dbo.open_credits cr,
     dbo.common_ewer_uah ceu,
     dbo.common_ewer_credit_uah cecu;

create view dbo.total_values(uah, usd_uah, eur_uah, pln_uah, fop_uah) as
SELECT tvuah.sum           AS uah,
       tvusd.sum * lcr.usd AS usd_uah,
       tve.sum * lcr.eur   AS eur_uah,
       tvp.sum * lcr.pln   AS pln_uah,
       tvfu.sum            AS fop_uah
FROM dbo.total_values_eur tve,
     dbo.total_values_usd tvusd,
     dbo.total_values_uah tvuah,
     dbo.total_values_pln tvp,
     dbo.total_values_fop_uah tvfu,
     dbo.last_current_rate lcr;

create view dbo.total_values_total(sum) as
SELECT tv.uah + tv.usd_uah + tv.eur_uah + tv.pln_uah + tv.fop_uah AS sum
FROM dbo.total_values tv;

create view dbo.total_values_percent (total_inuah, percent_uah, percent_usd, percent_eur, percent_pln, percent_fop) as
SELECT tvt.sum                                       AS total_inuah,
       round(tv.uah / tvt.sum * 100::numeric, 2)     AS percent_uah,
       round(tv.usd_uah / tvt.sum * 100::numeric, 2) AS percent_usd,
       round(tv.eur_uah / tvt.sum * 100::numeric, 2) AS percent_eur,
       round(tv.pln_uah / tvt.sum * 100::numeric, 2) AS percent_pln,
       round(tv.fop_uah / tvt.sum * 100::numeric, 2) AS percent_fop
FROM dbo.total_values tv,
     dbo.total_values_total tvt;