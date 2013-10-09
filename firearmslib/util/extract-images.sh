#! /bin/bash

cd "$(dirname "$0")";

mkdir -p "textures";

tex="firearms.png";

pfx="firearms_";

extract_one_weapon_icon()
{
	eval x=\$\(\( base_x + ${2}_xoff \)\);
	eval y=\$\(\( base_y + ${2}_yoff \)\);
	eval size=\$${2}_size;
	convert "$tex" -crop "${size}+${x}+${y}" "textures/${pfx}${1}_$2.png";
}

extract_weapon_icons()
{

	weapons="m9 m3 m4 awp";

	weapons_startx=0;
	weapons_starty=0;

	weapons_per_row=5;

	inv_size=16x16;
	inv_xoff=0;
	inv_yoff=0;

	hud_size=32x16;
	hud_xoff=0;
	hud_yoff=16;

	wield_size=32x32;
	wield_xoff=32;
	wield_yoff=0;

	total_xoff=64;
	total_yoff=32;

	index=0;

	for weapon in $weapons; do

		base_x=$(( weapons_startx + ((index % weapons_per_row) * total_xoff) ));
		base_y=$(( weapons_starty + ((index / weapons_per_row) * total_yoff) ));

		extract_one_weapon_icon "$weapon" inv;
		extract_one_weapon_icon "$weapon" hud;
		extract_one_weapon_icon "$weapon" wield;

		index=$((index+1));

	done

}

extract_bullet_icons()
{

	bullets="45 12g 556mm";

	bullets_startx=0;
	bullets_starty=32;

	bullets_per_row=10;

	bullet_size=16x16;
	bullet_xoff=16;
	bullet_yoff=16;

	index=0;

	for bullet in $bullets; do

		base_x=$(( bullets_startx + ((index % bullets_per_row) * bullet_xoff) ));
		base_y=$(( bullets_starty + ((index / bullets_per_row) * bullet_yoff) ));

		convert "$tex" -crop "${bullet_size}+${base_x}+${base_y}" "textures/${pfx}bullet_${bullet}_inv.png";

		index=$((index+1));

	done

}

extract_font()
{

	font_startx=1;
	font_starty=97;

	font_charw=11;
	font_charh=19;

	font_charoffx=1;
	font_charoffy=1;

	for char in 0 1 2 3 4 5 6 7 8 9 10; do
		base_x=$(( font_startx + (char * (font_charw + font_charoffx)) ));
		base_y=$(( font_starty ));
		if [ $char -gt 9 ]; then
			charname="0l";
		else
			charname="$char";
		fi
		convert "$tex" -crop "${font_charw}x${font_charh}+${base_x}+${base_y}" "textures/${pfx}font_${charname}.png"
	done

}

extract_misc_icons()
{

	convert "$tex" -crop 16x16+0+64  "textures/${pfx}shop.png";
	convert "$tex" -crop 16x16+16+64 "textures/${pfx}armor.png";
	convert "$tex" -crop 16x16+32+64 "textures/${pfx}medkit.png";
	convert "$tex" -crop 16x16+48+64 "textures/${pfx}nvg.png";

}

extract_weapon_icons;
extract_bullet_icons;
extract_font;
extract_misc_icons;
