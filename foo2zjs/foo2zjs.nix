#let
#  pkgs = import <nixpkgs> {};
#in
{ lib, stdenv, fetchurl, foomatic-filters, bc, ghostscript, systemd, vim, time, cups }:

stdenv.mkDerivation rec {
  pname = "foo2zjs";
  version = "20210116";

  srcs = [
    (fetchurl {
      url = "https://foo2zjs.linkevich.net/foo2zjs/foo2zjs.tar.gz";
      sha256 = "sha256-rXxy1lDHFIYWnoq2fz1OTzewQTGVQUgrrEX26h1oSOw=";
    })
    (fetchurl {
      url = "http://foo2zjs.linkevich.net/foo2zjs/firmware/sihpP1005.tar.gz";
      sha256 = "sha256-og5LVQpBi5miijINeDT1CuCxJvDLw7DoS6Dgv13ocqA=";
    })
  ];
      
  sourceRoot = "foo2zjs";

  buildInputs = [ 
    foomatic-filters 
    bc 
    ghostscript 
    systemd 
    vim
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "APPL=$(out)/share/applications"
    "PIXMAPS=$(out)/share/pixmaps"
    "UDEVBIN=$(out)/bin"
    "UDEVDIR=$(out)/etc/udev/rules.d"
    "UDEVD=${systemd}/sbin/udevd"
    "LIBUDEVDIR=$(out)/lib/udev/rules.d"
    "USBDIR=$(out)/etc/hotplug/usb"
    "FOODB=$(out)/share/foomatic/db/source"
    "MODEL=$(out)/share/cups/model"
  ];

  installFlags = [ "install-hotplug" ];

  postPatch = ''
    touch all-test
    sed -e "/BASENAME=/iPATH=$out/bin:$PATH" -i *-wrapper *-wrapper.in
    sed -e "s@PREFIX=/usr@PREFIX=$out@" -i *-wrapper{,.in}
    sed -e "s@/usr/share@$out/share@" -i hplj10xx_gui.tcl
    sed -e "s@\[.*-x.*/usr/bin/logger.*\]@type logger >/dev/null 2>\&1@" -i *wrapper{,.in}
    sed -e '/install-usermap/d' -i Makefile
    sed -e "s@/etc/hotplug/usb@$out&@" -i *rules*
    sed -e "s@/usr@$out@g" -i hplj1020.desktop
    sed -e "/PRINTERID=/s@=.*@=$out/bin/usb_printerid@" -i hplj1000
    substituteInPlace hplj1000 --replace "/usr/lib/cups/backend/usb" "${cups}/lib/cups/backend/usb"
    substituteInPlace hplj1000 --replace "/usr/share/foo2zjs/firmware" "$out/share/foo2zfs/firmware"
    substituteInPlace hplj1000 --replace "/usr/share/foo2xqx/firmware" "$out/share/foo2xqx/firmware"
    substituteInPlace hplj10xx.rules --replace "KERNEL==\"lp*\", " ""
    substituteInPlace hplj10xx.rules --replace "ATTRS{product}==\"HP LaserJet P1005\", " "ATTRS{idProduct}==\"3d17\", "
    substituteInPlace hplj10xx.rules --replace "KERNEL==\"lp*\", " ""
    
  '';


  checkInputs = [ time ];
  doCheck = false; # fails to find its own binary. Also says "Tests will pass only if you are using ghostscript-8.71-16.fc14".
  
  preInstall = ''
    mkdir -pv $out/{etc/udev/rules.d,lib/udev/rules.d,etc/hotplug/usb}
    mkdir -pv $out/share/foomatic/db/source/{opt,printer,driver}
    mkdir -pv $out/share/cups/model
    mkdir -pv $out/share/{applications,pixmaps}

    mkdir -pv "$out/bin"
    cp -v getweb arm2hpdl "$out/bin"
    cp ../sihpP1005.img .
  '';

  meta = with lib; {
    description = "ZjStream printer drivers";
    maintainers = with maintainers;
    [
      raskin
    ];
    platforms = platforms.linux;
    license = licenses.gpl2Plus;
  };
}
