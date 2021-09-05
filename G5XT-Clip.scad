
// Schlaufen Halterung für G5XT PMR Funkgerät

// Resolution for 3D printing:
$fa = 1;
$fs = 0.4;

// Allgemeines:
delta                  =   0.1; // Standard Durchdringung

clip_breite            =  16.0;
clip_laenge            =  11.5;
clip_hoehe             =   4.25 + delta;

oesen_basis_breite     =   6.7;
oesen_basis_laenge     =   4.0;
oesen_durchmesser      =  oesen_basis_breite;
loch_durchmesser       =  oesen_durchmesser - 2.5;

aussparung_breite      =   9.0;
aussparung_laenge      =  clip_laenge + 2*delta;
aussparung_hoehe       =   1.0;

schiene_breite         =   2.5;
schiene_laenge         =  10.0;
schiene_hoehe          =   2.5;

sperre_breite          =  oesen_basis_breite-1.0;
sperre_laenge          =   0.5;
sperre_y_offset        =  clip_laenge - schiene_laenge 
                         + 0.75;
sperre_hoehe           =   0.5;

nut_breite             =   1.2;
nut_laenge             =  schiene_laenge;
nut_hoehe              =   2.0;

deckel_breite          =  21.0;
deckel_laenge          =  clip_laenge;
deckel_hoehe           =   2.5;

module nut() {
    cube([nut_breite + delta,
          nut_laenge + 2*delta, 
          nut_hoehe]);
};

module schiene() {
    cube([schiene_breite + delta,
          schiene_laenge + 2*delta, 
          schiene_hoehe + delta]);
};

module schienen() {
    // Schiene links:
    translate([-delta, 
               clip_laenge - schiene_laenge - delta,
               clip_hoehe - schiene_hoehe + delta])
        schiene();
    // Schiene rechts:
    translate([clip_breite - schiene_breite + delta,
               clip_laenge - schiene_laenge - delta,
               clip_hoehe - schiene_hoehe + delta])
        schiene();
    
    // Nut links:
    translate([(clip_breite - aussparung_breite) / 2
               -delta, clip_laenge - nut_laenge - delta,
               +delta])
        nut();
    
    // Nut rechts:
    translate([clip_breite - nut_breite + 2*delta
               -(clip_breite - aussparung_breite) / 2
               - delta, clip_laenge - nut_laenge - delta,
               +delta])
        nut();    
};

module clip() {
    difference() {
        cube([clip_breite, clip_laenge, clip_hoehe]);
        schienen();
    };
};

module oesen_ring() {
    cylinder(clip_hoehe, d=oesen_durchmesser, center=true);
};

module oese() {
    // Ösen Basis:
    translate([(clip_breite - oesen_basis_breite) / 2,
                clip_laenge - delta, 0])
        cube([oesen_basis_breite, oesen_basis_laenge +
              delta, clip_hoehe]);
    // Ösenring:
    translate([clip_breite / 2,
               clip_laenge + oesen_basis_laenge,
               clip_hoehe / 2])
        oesen_ring();
};

module hole() {
    translate([deckel_breite / 2,
               clip_laenge + oesen_basis_laenge, 
               (clip_hoehe + deckel_hoehe) / 2 -delta])
        cylinder(clip_hoehe + deckel_hoehe + 2*delta,
                 d=loch_durchmesser, center=true); 
};

module bauteil_ohne_aussparung() {
    // Der Clip:
    clip();
    // Öse:
    oese();
};

module aussparung() {
    translate([(clip_breite - oesen_basis_breite) / 2 
               -delta,
               -delta,
               -delta])
        cube([oesen_basis_breite + 2*delta,
              clip_laenge + oesen_basis_laenge +
              oesen_durchmesser / 2 + 2*delta,
              aussparung_hoehe + delta]);
    
    translate([(clip_breite - aussparung_breite) / 2 
               -delta,
               -delta,
               -delta])
        cube([aussparung_breite + 2*delta,
              aussparung_laenge,
              aussparung_hoehe + delta]);
};

module sperre() {
    translate([(clip_breite - sperre_breite) / 2,
               sperre_y_offset,
               aussparung_hoehe - sperre_hoehe + delta])
        cube([sperre_breite, sperre_laenge,
              sperre_hoehe + delta]);
};

module deckel() {
    cube([deckel_breite, deckel_laenge + delta,
          deckel_hoehe]);
    translate([deckel_breite / 2,
               deckel_laenge - delta,
               deckel_hoehe / 2])
        cylinder(deckel_hoehe, d=deckel_breite, 
                 center=true);
};

module bauteil_ohne_deckel() {
    // Rastvorrichtung:
    difference() {
        bauteil_ohne_aussparung();
        aussparung();
    };
    sperre();
};

module bauteil_ohne_loch() {
    translate([(deckel_breite - clip_breite) / 2,
                0, 0])
        bauteil_ohne_deckel();
    translate([0, 0, clip_hoehe - delta])
        deckel();
};

module bauteil() {
    difference() {
        bauteil_ohne_loch();
        hole();
    };
};

// Hindrehen zum Drucken:
translate([0, deckel_laenge + deckel_breite / 2,
           clip_hoehe + deckel_hoehe])
    rotate([180, 0, 0])
        bauteil();