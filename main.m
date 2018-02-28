// Application abtps: abtps-[sw]/abtps-[smb]-[sw]
// GA/ABM - 1.0
// (C) 2000-2004 Matteo Morini <matteo.morini@unito.it>
// (C) 1999-2004 Gianluigi Ferraris <ferraris@econ.unito.it>

/* 
 *  This program is free software; you can redistribute it and/or modify 
 *  it under the terms of the GNU General Public License as published by 
 *  the Free Software Foundation; either version 2 of the License, or 
 *  (at your option) any later version.
 */

#import <simtools.h>             
#import "ObserverSwarm.h"

int
main (int argc, const char **argv)
{

  const char author1[]="(C) 2001-2004 Matteo Morini <matteo.morini@unito.it>";
  const char author2[]="(C) 2001-2004 Gianluigi Ferraris <ferraris@econ.unito.it>";
  const char copyleft[]="This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.";
  const char license[]="GNU GENERAL PUBLIC LICENSE Version 2, June 1991";

  ObserverSwarm *observerSwarm;

  strncmp(author1," ",1);
  strncmp(author2," ",1);
  strncmp(copyleft," ",1);
  strncmp(license," ",1);
  initSwarmApp (argc, argv, "1.0", "matteo.morini@unito.it");

    if((observerSwarm = 
	  [lispAppArchiver getWithZone: globalZone 
			 key: "batchSwarm"]) == nil ) {
	printf("Missing BatchSwarm parameters.\n");
      exit(1);

  }


  [observerSwarm buildObjects];
  [observerSwarm buildActions];
  [observerSwarm activateIn: nil];

  [observerSwarm go];

  return 0;

}


