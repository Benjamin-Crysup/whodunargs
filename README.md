# ArgMang

Do things to help with arguments\.

- [htmlp](#htmlp) : Generate html documentation for a program\.
- [htmls](#htmls) : Generate html documentation for a program set\.
- [manp](#manp) : Generate a manpage for a program\.
- [mans](#mans) : Generate manpages for a program set\.
- [mdp](#mdp) : Generate markdown documentation for a program\.
- [mds](#mds) : Generate markdown documentation for a program set\.
- [latexp](#latexp) : Generate latex documentation for a program\.
- [latexs](#latexs) : Generate latex documentation for a program set\.
- [guip](#guip) : Show a helpful gui for a program\.
- [guis](#guis) : Show a helpful gui for a program set\.


# htmlp

Generate html documentation for a program\.

- \-\-prog python3

    The executable to run to get data\.
- \-\-arg WDAExample\.py

    Any required arguments to the program\.
- \-\-out /home/ben/WDAExample\.html

    Where to write the html\.


# htmls

Generate html documentation for a program set\.

- \-\-prog python3

    The executable to run to get data\.
- \-\-arg WDAExample\.py

    Any required arguments to the program\.
- \-\-out /home/ben/ArgMang\.html

    Where to write the html\.


# manp

Generate a manpage for a program\.

- \-\-prog python3

    The executable to run to get data\.
- \-\-arg WDAExample\.py

    Any required arguments to the program\.
- \-\-out /home/ben/WDAExample\.1

    Where to write the troff file\.


# mans

Generate manpages for a program set\.

- \-\-prog python3

    The executable to run to get data\.
- \-\-arg WDAExample\.py

    Any required arguments to the program\.
- \-\-out /home/ben/ArgMang/

    Where to write the files\.
- \-\-pref argmang

    The prefix for the file names\.


# mdp

Generate markdown documentation for a program\.

- \-\-prog python3

    The executable to run to get data\.
- \-\-arg WDAExample\.py

    Any required arguments to the program\.
- \-\-out /home/ben/WDAExample\.md

    Where to write the md file\.


# mds

Generate markdown documentation for a program set\.

- \-\-prog python3

    The executable to run to get data\.
- \-\-arg WDAExample\.py

    Any required arguments to the program\.
- \-\-out /home/ben/ArgMang\.md

    Where to write the md file\.


# latexp

Generate latex documentation for a program\.

- \-\-prog python3

    The executable to run to get data\.
- \-\-arg WDAExample\.py

    Any required arguments to the program\.
- \-\-out /home/ben/WDAExample\.tex

    Where to write the latex file\.


# latexs

Generate latex documentation for a program set\.

- \-\-prog python3

    The executable to run to get data\.
- \-\-arg WDAExample\.py

    Any required arguments to the program\.
- \-\-out /home/ben/ArgMang\.tex

    Where to write the latex file\.


# guip

Build a gui to pick arguments for a program, then run\.

MacOS: The default python has a busted tkinter\. Reinstall from python\.org\.

- \-\-prog python3

    The executable to run to get data\.
- \-\-arg WDAExample\.py

    Any required arguments to the program\.


# guis

Build a gui to pick arguments for a set of programs, then run\.

MacOS: The default python has a busted tkinter\. Reinstall from python\.org\.

- \-\-prog python3

    The executable to run to get data\.
- \-\-arg WDAExample\.py

    Any required arguments to the program\.


