module RadicalUtils
  @@han_table = {10 => ?一, 20 => ?丨, 30 => ?丶, 40 => ?丿, 50 => ?乙, 60 => ?亅, 70 => ?二, 80 => ?亠, 90 => ?人, 100 => ?儿, 110 => ?入, 120 => ?八, 130 => ?冂, 140 => ?冖, 150 => ?冫, 160 => ?几, 170 => ?凵, 180 => ?刀, 190 => ?力, 200 => ?勹, 210 => ?匕, 220 => ?匚, 230 => ?匸, 240 => ?十, 250 => ?卜, 260 => ?卩, 270 => ?厂, 280 => ?厶, 290 => ?又, 300 => ?口, 310 => ?囗, 320 => ?土, 330 => ?士, 340 => ?夂, 350 => ?夊, 360 => ?夕, 370 => ?大, 380 => ?女, 390 => ?子, 400 => ?宀, 410 => ?寸, 420 => ?小, 430 => ?尢, 440 => ?尸, 450 => ?屮, 460 => ?山, 470 => ?巛, 480 => ?工, 490 => ?己, 500 => ?巾, 510 => ?干, 520 => ?幺, 530 => ?广, 540 => ?廴, 550 => ?廾, 560 => ?弋, 570 => ?弓, 580 => ?彐, 590 => ?彡, 600 => ?彳, 610 => ?心, 620 => ?戈, 630 => ?戶, 640 => ?手, 650 => ?支, 660 => ?攴, 670 => ?文, 680 => ?斗, 690 => ?斤, 700 => ?方, 710 => ?无, 720 => ?日, 730 => ?曰, 740 => ?月, 750 => ?木, 760 => ?欠, 770 => ?止, 780 => ?歹, 790 => ?殳, 800 => ?毋, 810 => ?比, 820 => ?毛, 830 => ?氏, 840 => ?气, 850 => ?水, 860 => ?火, 870 => ?爪, 880 => ?父, 890 => ?爻, 900 => ?爿, 910 => ?片, 920 => ?牙, 930 => ?牛, 940 => ?犬, 950 => ?玄, 960 => ?玉, 970 => ?瓜, 980 => ?瓦, 990 => ?甘, 1000 => ?生, 1010 => ?用, 1020 => ?田, 1030 => ?疋, 1040 => ?疒, 1050 => ?癶, 1060 => ?白, 1070 => ?皮, 1080 => ?皿, 1090 => ?目, 1100 => ?矛, 1110 => ?矢, 1120 => ?石, 1130 => ?示, 1140 => ?禸, 1150 => ?禾, 1160 => ?穴, 1170 => ?立, 1180 => ?竹, 1190 => ?米, 1200 => ?糸, 1210 => ?缶, 1220 => ?网, 1230 => ?羊, 1240 => ?羽, 1250 => ?老, 1260 => ?而, 1270 => ?耒, 1280 => ?耳, 1290 => ?聿, 1300 => ?肉, 1310 => ?臣, 1320 => ?自, 1330 => ?至, 1340 => ?臼, 1350 => ?舌, 1360 => ?舛, 1370 => ?舟, 1380 => ?艮, 1390 => ?色, 1400 => ?艸, 1410 => ?虍, 1420 => ?虫, 1430 => ?血, 1440 => ?行, 1450 => ?衣, 1460 => ?西, 1470 => ?見, 1480 => ?角, 1490 => ?言, 1500 => ?谷, 1510 => ?豆, 1520 => ?豕, 1530 => ?豸, 1540 => ?貝, 1550 => ?赤, 1560 => ?走, 1570 => ?足, 1580 => ?身, 1590 => ?車, 1600 => ?辛, 1610 => ?辰, 1620 => ?辵, 1630 => ?邑, 1640 => ?酉, 1650 => ?釆, 1660 => ?里, 1670 => ?金, 1680 => ?長, 1690 => ?門, 1700 => ?阜, 1710 => ?隶, 1720 => ?隹, 1730 => ?雨, 1740 => ?靑, 1750 => ?非, 1760 => ?面, 1770 => ?革, 1780 => ?韋, 1790 => ?韭, 1800 => ?音, 1810 => ?頁, 1820 => ?風, 1830 => ?飛, 1840 => ?食, 1850 => ?首, 1860 => ?香, 1870 => ?馬, 1880 => ?骨, 1890 => ?高, 1900 => ?髟, 1910 => ?鬥, 1920 => ?鬯, 1930 => ?鬲, 1940 => ?鬼, 1950 => ?魚, 1960 => ?鳥, 1970 => ?鹵, 1980 => ?鹿, 1990 => ?麥, 2000 => ?麻, 2010 => ?黃, 2020 => ?黍, 2030 => ?黑, 2040 => ?黹, 2050 => ?黽, 2060 => ?鼎, 2070 => ?鼓, 2080 => ?鼠, 2090 => ?鼻, 2100 => ?齊, 2110 => ?齒, 2120 => ?龍, 2130 => ?龜, 2140 => ?龠,
  901 => ?丬, 1201 => ?纟, 1471 => ?见, 1491 => ?讠, 1541 => ?贝, 1591 => ?车, 1671 => ?钅, 1681 => ?长, 1691 => ?门, 1781 => ?韦, 1811 => ?页, 1821 => ?风, 1831 => ?飞, 1841 => ?饣, 1871 => ?马, 1951 => ?鱼, 1961 => ?鸟, 1971 => ?卤, 1991 => ?麦, 2051 => ?黾, 2101 => ?齐, 2111 => ?齿, 2121 => ?龙, 2131 => ?龟}
  @@kx_table = (1..214).map { |n| [n*10, (0x2EFF+n).chr('UTF-8')] }.to_h.merge({
    901 => ?\u2EA6, 1201 => ?\u2EB0, 1471 => ?\u2EC5, 1491 => ?\u2EC8, 1541 => ?\u2EC9, 1591 => ?\u2ECB, 1671 => ?\u2ED0, 1681 => ?\u2ED3, 1691 => ?\u2ED4, 1781 => ?\u2ED9, 1811 => ?\u2EDA, 1821 => ?\u2EDB, 1831 => ?\u2EDC, 1841 => ?\u2EE0, 1871 => ?\u2EE2, 1951 => ?\u2EE5, 1961 => ?\u2EE6, 1971 => ?\u2EE7, 1991 => ?\u2EE8, 2051 => ?\u2EEA, 2101 => ?\u2EEC, 2111 => ?\u2EEE, 2121 => ?\u2EF0, 2131 => ?\u2EF3
  })

  def lookup_han(num)
    _lookup num, false
  end
  def lookup_kx(num)
    _lookup num, true
  end
  def rads
    @@han_table.sort_by { |k, v| k }.map { |e| [ e[0], [e[1], @@kx_table[e[0]]] ] }.to_h
  end

  private

  def _lookup(num, kangxi)
    n = _rad_normalize(num)
    kangxi ? @@kx_table[n] : @@han_table[n]
  end
  def _rad_normalize(num)
    case num
    when Integer; num
    when Float; (num * 10).round
    else; nil
    end
  end
end

module BuilderUtils
  def query_list(set)
    set.chars(:c, :r).query_as(:c, :r)
      .where_not('(c)-[:REDIRECTS_FROM]-()')
      .with(serial: 'r.serial', code: 'c.code')
      .return(:serial, :code)
      .order(:serial)
      .to_a.map(&:to_h)
  end
  
  def query_browse(set, where, rel = true)
    wheres = rel ? [{}, {serial: where}] : [{code: where}, {}]
    set.chars(:c).where(wheres[0]).rel_where(wheres[1])
      .motions(:m).document.query_as(:d)
      .optional_match('(m)-[:HAS_GLYPH]->(g)').break
      .optional_match('(m)-[:HAS_EVIDENCE]->(e)').break
      .optional_match('(d)-[:CONTAINS]->(um:CharMotion)-[:UNIFIED_BY]->(c)').break
      .optional_match('(um)-[:HAS_GLYPH]->(ug)').break
      .optional_match('(um)-[:HAS_EVIDENCE]->(ue)').break
      .optional_match('(um)-[:ON]->(uc)').break # all optional matches must be independent
      .optional_match('(m)-[:UNIFIED_BY]->(u2:Character)-[u2r:CONSTITUTES]->(u2s:Series)')
      .where("EXISTS(u2r.serial) OR u2s.short_name = 'UC'").break # 'UC' -> Unicode
      .with(:c, :m, :g, :d, :e, :um, :uc, :ug, uee: 'collect(ue)',
        uf: 'CASE WHEN u2 IS NOT NULL THEN {code: u2.code, in: collect({serial: u2r.serial, series: u2s.short_name})} ELSE NULL END'
      )
      .with(
        source: 'c.code',
        motion: :m,
        glyph: :g,
        document: :d,
        unifies: 'CASE WHEN um IS NOT NULL THEN collect({motion: um, source: uc.code, glyph: ug, evidences: uee, document: d}) ELSE NULL END',
        unified: 'collect(uf)',
        evidences: 'collect(e)',
        sorting: 'CASE WHEN d.published_on IS NOT NULL THEN d.published_on ELSE d.assigned_on END'
      )
      .return(:source, :motion, :glyph, :evidences, :unifies, :unified, :document)
      .order('sorting DESC')
      .map { |e|
        array = [[e.to_h.except(:unifies), true]]
        array.push( *( e.unifies.map { |u| [u, false] if u.present? }.compact ) ) if e.unifies
        array
      }
      .flatten(1)
  end

  def query_motion_gallery(doc, start=0, range=200)
    doc.motions(:m).char.query_as(:c)
      .optional_match('(m)-[:HAS_GLYPH]->(g)').break
      .optional_match('(c)-[cr:CONSTITUTES]->(cs:Series)').break
      .with(
        source: 'c.code',
        in: 'collect({serial: cr.serial, series: cs.short_name})',
        glyph: 'CASE WHEN g IS NOT NULL THEN g.name ELSE NULL END',
        filetype: 'CASE WHEN g IS NOT NULL THEN g.filetype ELSE NULL END',
        path: 'CASE WHEN g.path IS NOT NULL THEN g.path ELSE NULL END',
        status: 'm.status'
      )
      .return(:source, :in, :glyph, :filetype, :path, :status)
      .order('status ASC, source ASC')
      .skip(start).limit(range)
      .to_a.map(&:to_h)
  end
end