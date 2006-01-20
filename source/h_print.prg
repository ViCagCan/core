/*
 * $Id: h_print.prg,v 1.1 2006-01-20 05:47:17 guerra000 Exp $
 */

#include 'hbclass.ch'
#include 'common.ch'
#include 'oohg.ch'
#include 'miniprint.ch'
#include 'winprint.ch'


CREATE CLASS TPRINT

DATA cprintlibrary      INIT "HBPRINTER"
DATA nfontsize          INIT 10
DATA nmhor              INIT (10)/4.75
DATA nmver              INIT (10)/2.45
DATA nhfij              INIT (12/3.70)
DATA nvfij              INIT (12/1.65)
DATA cunits             INIT "ROWCOL"
DATA cprinter           INIT ""

DATA aprinters          INIT {}
DATA aports             INIT {}

DATA lprerror           INIT .F.
DATA exit               INIT  .F.
DATA acolor             INIT {1,1,1}
DATA cfontname          INIT "courier new"
DATA nfontsize          INIT 10
DATA nwpen              INIT 0.1   //// ancho del pen
DATA tempfile           INIT gettempdir()+"T"+alltrim(str(int(hb_random(999999)),8))+".prn"
DATA impreview          INIT .F.

*-------------------------
METHOD init()
*-------------------------
*-------------------------
METHOD begindoc()
*-------------------------
*-------------------------
METHOD enddoc()

method printdos()
*-------------------------
*-------------------------
METHOD beginpage()
*-------------------------

METHOD condendos()

METHOD NORMALDOS()

*-------------------------
METHOD endpage()
*-------------------------
*-------------------------
METHOD release()
*-------------------------
*-------------------------
METHOD printdata()
*-------------------------
*-------------------------
METHOD printimage
*-------------------------
*-------------------------
METHOD printline
*-------------------------

METHOD printrectangle
*-------------------------

METHOD selprinter()
*-------------------------
*-------------------------

METHOD getdefprinter()
*-------------------------

METHOD setcolor()



METHOD setpreviewsize()

*-------------------------
METHOD setunits()   ////// mm o rowcol
*-------------------------

METHOD printroundrectangle()

ENDCLASS


METHOD condenDOS() CLASS TPRINT
if ::cprintlibrary="DOS"
   @ prow(), pcol() say chr(15)
endif
return nil


method normaldos() CLASS TPRINT
if ::cprintlibrary="DOS"
   @ prow(), pcol() say chr(18)
endif
return nil

METHOD setpreviewsize(ntam)
if ntam=NIL .or. ntam>5
   ntam=1
endif
if ::cprintlibrary="HBPRINTER"
   SET PREVIEW SCALE ntam
endif
return nil

*-------------------------
METHOD release() CLASS TPRINT
*-------------------------
if ::exit
   return
endif
do case
case ::cprintlibrary="HBPRINTER"
        RELEASE PRINTSYS
        RELEASE HBPRN
case ::cprintlibrary="MINIPRINT"
release _HMG_PRINTER_APRINTERPROPERTIES
release _HMG_PRINTER_HDC
release _HMG_PRINTER_COPIES
release _HMG_PRINTER_COLLATE
release _HMG_PRINTER_PREVIEW
release _HMG_PRINTER_TIMESTAMP
release _HMG_PRINTER_NAME
release _HMG_PRINTER_PAGECOUNT
release _HMG_PRINTER_HDC_BAK
endcase
RETURN NIL


*-------------------------
METHOD init(clibx) CLASS TPRINT
*-------------------------
if iswindowactive(_winreport)
   msgstop("Print preview pending, close first")
   ::exit:=.T.
   return
endif
if clibx=NIL
   if _OOHG_printlibrary#NIL
      ::cprintlibrary:=upper(_OOHG_PRINTLIBRARY)
   else
      ::cprintlibrary:="HBPRINTER"
   endif
else
     ::cprintlibrary:=upper(clibx)
endif

do case
case ::cprintlibrary="HBPRINTER"
   public hbprn
   INIT PRINTSYS
   GET PRINTERS TO ::aprinters
   GET PORTS TO ::aports
   SET UNITS MM
case ::cprintlibrary="MINIPRINT"

public _HMG_PRINTER_APRINTERPROPERTIES
public _HMG_PRINTER_HDC
public _HMG_PRINTER_COPIES
public  _HMG_PRINTER_COLLATE
public _HMG_PRINTER_PREVIEW
public _HMG_PRINTER_TIMESTAMP
public _HMG_PRINTER_NAME
public _HMG_PRINTER_PAGECOUNT
public _HMG_PRINTER_HDC_BAK

::aprinters:=aprinters()

case ::cprintlibrary="DOS"
::impreview:=.F.
endcase
return nil

*-------------------------
METHOD selprinter( lselect , lpreview, llandscape , npapersize ) CLASS TPRINT
*-------------------------
local lsucess:=.T. 
if ::exit
   ::lprerror:=.T.
   return
endif
SETPRC(0,0)
if llandscape=NIL
   llandscape:=.F.
endif

do case
case ::cprintlibrary="HBPRINTER"
   if lselect .and. lpreview
      SELECT BY DIALOG PREVIEW
   endif
   if lselect .and. (.not. lpreview)
      SELECT BY DIALOG
   endif
   if (.not. lselect) .and. lpreview
      SELECT DEFAULT PREVIEW
   endif
   if (.not. lselect) .and. (.not. lpreview)
      SELECT DEFAULT
   endif
   IF HBPRNERROR != 0
      ::lprerror:=.T.
      return nil
   ENDIF
   define font "f0" name ::cfontname size ::nfontsize
   define font "f1" name ::cfontname size ::nfontsize BOLD
   define pen "C0" WIDTH ::nwpen COLOR ::acolor
   select pen "C0"
   if llandscape
      set page orientation DMORIENT_LANDSCAPE font "f0"
   else
      set page orientation DMORIENT_PORTRAIT  font "f0"
   endif
   if npapersize#NIL
      set page papersize npapersize
   endif
case ::cprintlibrary="MINIPRINT"
   if llandscape
      Worientation:= PRINTER_ORIENT_LANDSCAPE
   else
      Worientation:= PRINTER_ORIENT_PORTRAIT
   endif

   if lselect .and. lpreview
      ::cPrinter := GetPrinter()
      If Empty (::cPrinter)
         ::lprerror:=.T.
         Return Nil
      EndIf
      
      if npapersize#NIL
         SELECT PRINTER ::cprinter to lsucess ;
         ORIENTATION worientation ;
         PAPERSIZE npapersize       ;
         PREVIEW
      else
         SELECT PRINTER ::cprinter to lsucess ;
         ORIENTATION worientation ;
         PREVIEW
      endif
   endif
   
   if (.not. lselect) .and. lpreview
      
      if npapersize#NIL
         SELECT PRINTER DEFAULT TO lsucess ;
         ORIENTATION worientation  ;
         PAPERSIZE npapersize       ;
         PREVIEW
      else
         SELECT PRINTER DEFAULT TO lsucess ;
         ORIENTATION worientation  ;
         PREVIEW
      endif
   endif
   
   if (.not. lselect) .and. (.not. lpreview)
      
      if npapersize#NIL
         SELECT PRINTER DEFAULT TO lsucess  ;
         ORIENTATION worientation  ;
         PAPERSIZE npapersize
      else
         SELECT PRINTER DEFAULT TO lsucess  ;
         ORIENTATION worientation
      endif
   endif

   if lselect .and. .not. lpreview
      ::cPrinter := GetPrinter()
      If Empty (::cPrinter)
         ::lprerror:=.T.
         Return Nil
      EndIf
      
      if npapersize#NIL
         SELECT PRINTER ::cprinter to lsucess ;
         ORIENTATION worientation ;
         PAPERSIZE npapersize       
      else
         SELECT PRINTER ::cprinter to lsucess ;
         ORIENTATION worientation 
      endif
   endif

   IF .NOT. lsucess
      ::lprerror:=.T.
      return nil
   ENDIF
case ::cprintlibrary="DOS"
      do while file(::tempfile)
         ::tempfile:=gettempdir()+"T"+alltrim(str(int(hb_random(999999)),8))+".prn"
      enddo
if lpreview
   ::impreview:=.T.
endif
endcase

RETURN nil

*-------------------------
METHOD BEGINDOC(cdoc) CLASS TPRINT
*-------------------------
IF cdoc=NIL
   cDOc:=""
endif

DEFINE WINDOW _modalhide ;
        AT 0,0 ;
        WIDTH 0 HEIGHT 0 ;
        TITLE cdoc MODAL NOSHOW NOSIZE NOSYSMENU NOCAPTION  ;


end window


DEFINE WINDOW _winreport ;
        AT 0,0 ;
        WIDTH 400 HEIGHT 120 ;
        TITLE cdoc CHILD NOSIZE NOSYSMENU NOCAPTION ;

        @ 15,195 IMAGE IMAGE_101 OF _winreport ;
        picture 'hbprint_print'  ;
        WIDTH 25  ;
        HEIGHT 30 ;
        STRETCH

        @ 22,225 LABEL LABEL_101 VALUE '......' FONT "Courier new" SIZE 10

        @ 55,10  label label_1 value cdoc WIDTH 400 HEIGHT 32 FONT "Courier new"

        DEFINE TIMER TIMER_101 OF _winreport ;
        INTERVAL 1000  ;
        ACTION action_timer()

        end window
        center window _winreport
        activate window _modalhide NOWAIT
        activate window _winreport NOWAIT        

do case
case ::cprintlibrary="HBPRINTER"
   START DOC
case ::cprintlibrary="MINIPRINT"
   START PRINTDOC
case ::cprintlibrary="DOS"
   SET PRINTER TO &(::tempfile)
   SET DEVICE TO PRINT
endcase

RETURN nil


function action_timer()
if iswindowdefined(_winreport)
   _winreport.label_1.fontbold:=IIF(_winreport.label_1.fontbold,.F.,.T.)
   _winreport.image_101.visible:=IIF(_winreport.label_1.fontbold,.T.,.F.)
endif
return nil


*-------------------------
METHOD ENDDOC() CLASS TPRINT
*-------------------------
local _nhandle
do case
case ::cprintlibrary="HBPRINTER"
   END DOC
case ::cprintlibrary="MINIPRINT"
   END PRINTDOC
case ::cprintlibrary="DOS"
   SET DEVICE TO SCREEN
   SET PRINTER TO   
   _nhandle:=FOPEN(::tempfile,0+64) 
   if ::impreview
         wr:=hb_oemtoansi(memoread((::tempfile)))
   DEFINE WINDOW PRINT_PREVIEW  ;
   	AT 10,10 ;
   	   WIDTH 640 HEIGHT 480 ;
   	   TITLE 'Preview -----> ' + ::tempfile ;
   	   MODAL
  
   	@ 0,0 EDITBOX EDIT_P ;
   	OF PRINT_PREVIEW ;
   	WIDTH 590 ;
   	HEIGHT 440 ;
   	VALUE WR ;
   	READONLY ;
   	FONT 'Courier new' ;
   	SIZE 10

        @ 10,600 button but_4 caption "X" width 30 action ( print_preview.release() )
        @ 110,600 button but_1 caption "+ +" width 30 action zoom("+")
        @ 210,600 button but_2 caption "- -" width 30 action zoom("-")
        @ 310,600 button but_3 caption "P" width 30 action (::printdos())

  
   END WINDOW
   
   CENTER WINDOW PRINT_PREVIEW
   ACTIVATE WINDOW PRINT_PREVIEW

   else

      ::PRINTDOS()

   endif

   IF FILE(::tempfile)
      fclose(_nhandle)
      ERASE &(::tempfile)
   ENDIF
endcase

_winreport.release()
_modalhide.release()

RETURN self

METHOD SETCOLOR(atColor) CLASS TPRINT
::acolor:=atColor
if ::cprintlibrary="HBPRINTER"
   CHANGE PEN "C0" WIDTH ::nwpen COLOR ::acolor
   SELECT PEN "C0"   
endif
RETURN NIL

*-------------------------
METHOD beginPAGE() CLASS TPRINT
*-------------------------
do case
case ::cprintlibrary="HBPRINTER"
   START PAGE
case ::cprintlibrary="MINIPRINT"
   START PRINTPAGE
case ::cprintlibrary="DOS"
   @ 0,0 SAY ""
endcase
RETURN self

*-------------------------
METHOD ENDPAGE() CLASS TPRINT
*-------------------------
do case
case ::cprintlibrary="HBPRINTER"
   END PAGE
case ::cprintlibrary="MINIPRINT"
   END PRINTPAGE
case ::cprintlibrary="DOS"
   EJECT
endcase
RETURN self

*-------------------------
METHOD getdefprinter() CLASS TPRINT
*-------------------------
local cdefprinter
do case
case ::cprintlibrary="HBPRINTER"
   GET DEFAULT PRINTER TO cdefprinter
case ::cprintlibrary="MINIPRINT"
   cdefprinter:=GetDefaultPrinter()
endcase
RETURN cdefprinter


*-------------------------
METHOD setunits(cunitsx) CLASS TPRINT
*-------------------------
if cunitsx="MM"
   ::cunits:="MM"
else
   ::cunits:="ROWCOL"
endif
RETURN nil

*-------------------------
METHOD printdata(nlin,ncol,data,cfont,nsize,lbold,acolor,calign,nlen) CLASS TPRINT
*-------------------------
local ctext,cspace
do case
    case valtype(data)=='C' 
                ctext:=data
    case valtype(data)=='N'
                ctext:=alltrim(str(data))
    case valtype(data)=='D'
                ctext:=dtoc(data)
    case valtype(data)=='L'
               ctext:= iif(data,'T','F')  
    case valtype(data)=='M'  
               ctext:=data
    otherwise
               ctext:=""
endcase

if calign=NIL
   calign:="L"
endif

if nlen=NIL
   nlen=len(ctext)
endif

do case
   case calign = "L"
        cspace=""        
   case calign = "C"
        cspace=  space((int(nlen)-len(ctext))/2 )
   case calign = "R"
        cspace = space(int(nlen)-len(ctext))
   otherwise
        cspace = ""
endcase   

if nlin=nil
   nlin:=1
endif
if ncol=nil
   ncol:=1
endif
if ctext=NIL
   ctext=""
endif
if lbold=NIL
   lbold:=.F.
endif
if cfont=NIL
   cfont:=::cfontname
endif
if nsize=NIL
   nsize:=::nfontsize
endif

if acolor=NIL
   acolor:=::acolor
endif

if ::cunits="MM"
   ::nmver:=1
   ::nvfij:=0
   ::nmhor:=1
   ::nhfij:=0
else
   ::nmhor  := (::nfontsize)/4.75
   ::nmver  := (::nfontsize)/2.45
   ::nvfij  := (12/1.65)
   ::nhfij  := (12/3.70)
endif

ctext:=cspace + ctext

do case
case ::cprintlibrary="HBPRINTER"
     change font "F0" name cfont size nsize
     change font "F1" name cfont size nsize BOLD
     SET TEXTCOLOR ::acolor
   if .not. lbold
      @ nlin*::nmver+::nvfij,ncol*::nmhor+::nhfij*2 SAY hb_oemtoansi(ctext) font "F0" TO PRINT
   else
      @ nlin*::nmver+::nvfij,ncol*::nmhor+::nhfij*2 SAY hb_oemtoansi(ctext) font "F1" TO PRINT
   endif
case ::cprintlibrary="MINIPRINT"
   if .not. lbold
      @ nlin*::nmver+::nvfij, ncol*::nmhor+ ::nhfij*2 PRINT hb_oemtoansi(ctext) font cfont size nsize COLOR ::acolor
   else
      @ nlin*::nmver+::nvfij, ncol*::nmhor+ ::nhfij*2 PRINT hb_oemtoansi(ctext) font cfont size nsize  BOLD COLOR ::acolor
   endif
case ::cprintlibrary="DOS"
   if .not. lbold
       @ nlin,ncol say (ctext)
   else   
       @ nlin,ncol say (ctext)
//////       @ nlin,ncol say hb_oemtoansi(ctext)
   endif
endcase
RETURN self

*-------------------------
METHOD printimage(nlin,ncol,nlinf,ncolf,cimage) CLASS TPRINT
*-------------------------
if nlin=NIL
   nlin:=1
endif
if ncol=NIL
   ncol=1
endif
if cimage=NIL
   cimage:=""
endif
if nlinf=NIL
   nlinf:=4
endif
if ncolf=NIL
   ncolf=4
endif

if ::cunits="MM"
   ::nmver:=1
   ::nvfij:=0
   ::nmhor:=1
   ::nhfij:=0
else
   ::nmhor  := (::nfontsize)/4.75
   ::nmver  := (::nfontsize)/2.45
   ::nvfij  := (12/1.65)
   ::nhfij  := (12/3.70)
endif
do case
case ::cprintlibrary="HBPRINTER"
   @  nlin*::nmver+::nvfij ,ncol*::nmhor+::nhfij*2 PICTURE cimage SIZE  (nlinf+0.5-nlin-4)*::nmver+::nvfij , (ncolf-ncol-3)*::nmhor+::nhfij*2
case ::cprintlibrary="MINIPRINT"
   @  nlin*::nmver+::nvfij , ncol*::nmhor+::nhfij*2 PRINT IMAGE cimage WIDTH ((ncolf - ncol-1)*::nmhor + ::nhfij) HEIGHT ((nlinf+0.5 - nlin)*::nmver+::nvfij)
endcase
RETURN nil


*-------------------------
METHOD printline(nlin,ncol,nlinf,ncolf,atcolor,ntwpen ) CLASS TPRINT
*-------------------------
if nlin=NIL
   nlin:=1
endif
if ncol=NIL
   ncol=1
endif
if nlinf=NIL
   nlinf:=4
endif
if ncolf=NIL
   ncolf:=4
endif
if atcolor=NIL
   atcolor:= ::acolor
endif

if ntwpen=NIL
   ntwpen:= ::nwpen
endif

if ::cunits="MM"
   ::nmver:=1
   ::nvfij:=0
   ::nmhor:=1
   ::nhfij:=0
else
   ::nmhor  := (::nfontsize)/4.75
   ::nmver  := (::nfontsize)/2.45
   ::nvfij  := (12/1.65)
   ::nhfij  := (12/3.70)
endif


do case
case ::cprintlibrary="HBPRINTER"
   CHANGE PEN "C0" WIDTH ntwpen*10  COLOR atcolor
   SELECT PEN "C0"
   @  nlin*::nmver+::nvfij,ncol*::nmhor+::nhfij*2 , (nlinf)*::nmver+::nvfij,ncolf*::nmhor+::nhfij*2  LINE PEN "C0"  //// CPEN
case ::cprintlibrary="MINIPRINT"
   @  (nlin+.2)*::nmver+::nvfij,ncol*::nmhor+::nhfij*2 PRINT LINE TO  (nlinf+.2)*::nmver+::nvfij,ncolf*::nmhor+::nhfij*2  COLOR atcolor PENWIDTH ntwpen  //// CPEN
case ::cprintlibrary="DOS"
  if nlin=nlinf
     @ nlin,ncol say replicate("-",ncolf-ncol+1)
  endif
endcase
RETURN nil

*-------------------------
METHOD printrectangle(nlin,ncol,nlinf,ncolf,atcolor,ntwpen ) CLASS TPRINT
*-------------------------
if nlin=NIL
   nlin:=1
endif
if ncol=NIL
   ncol=1
endif
if nlinf=NIL
   nlinf:=4
endif
if ncolf=NIL
   ncolf:=4
endif

if atcolor=NIL
   atcolor:= ::acolor
endif

if ntwpen=NIL
   ntwpen:= ::nwpen
endif

if ::cunits="MM"
   ::nmver:=1
   ::nvfij:=0
   ::nmhor:=1
   ::nhfij:=0
else
   ::nmhor  := (::nfontsize)/4.75
   ::nmver  := (::nfontsize)/2.45
   ::nvfij  := (12/1.65)
   ::nhfij  := (12/3.70)
endif
do case
case ::cprintlibrary="HBPRINTER"
   CHANGE PEN "C0" WIDTH ntwpen*10 COLOR atcolor
   SELECT PEN "C0"
   @  nlin*::nmver+::nvfij,ncol*::nmhor+::nhfij*2, (nlinf+0.5)*::nmver+::nvfij, ncolf*::nmhor+::nhfij*2  RECTANGLE  PEN "C0" //// CPEN  RECTANGLE  ///// [PEN <cpen>] [BRUSH <cbrush>]
case ::cprintlibrary="MINIPRINT"
   @  nlin*::nmver+::nvfij,ncol*::nmhor+::nhfij*2 PRINT RECTANGLE TO  (nlinf+0.5)*::nmver+::nvfij,ncolf*::nmhor+::nhfij*2 COLOR atcolor  PENWIDTH ntwpen  //// CPEN
endcase
RETURN nil


METHOD printroundrectangle(nlin,ncol,nlinf,ncolf,atcolor,ntwpen ) CLASS TPRINT
*-------------------------
if nlin=NIL
   nlin:=1
endif
if ncol=NIL
   ncol=1
endif
if nlinf=NIL
   nlinf:=4
endif
if ncolf=NIL
   ncolf:=4
endif

if atcolor=NIL
   atcolor:= ::acolor
endif

if ntwpen=NIL
   ntwpen:= ::nwpen
endif

if ::cunits="MM"
   ::nmver:=1
   ::nvfij:=0
   ::nmhor:=1
   ::nhfij:=0
else
   ::nmhor  := (::nfontsize)/4.75
   ::nmver  := (::nfontsize)/2.45
   ::nvfij  := (12/1.65)
   ::nhfij  := (12/3.70)
endif
do case
case ::cprintlibrary="HBPRINTER"
   CHANGE PEN "C0" WIDTH ntwpen*10 COLOR atcolor
   SELECT PEN "C0"
    hbprn:RoundRect( nlin*::nmver+::nvfij  ,ncol*::nmhor+::nhfij*2 ,(nlinf+0.5)*::nmver+::nvfij ,ncolf*::nmhor+::nhfij*2 ,10, 10,"C0")
case ::cprintlibrary="MINIPRINT"
   @  nlin*::nmver+::nvfij,ncol*::nmhor+::nhfij*2 PRINT RECTANGLE TO  (nlinf+0.5)*::nmver+::nvfij,ncolf*::nmhor+::nhfij*2 COLOR atcolor  PENWIDTH ntwpen  ROUNDED //// CPEN
endcase
RETURN nil

method printdos() CLASS TPRINT
    cbat:='b'+alltrim(str(random(999999),6))+'.bat'
    set printer to &cbat
    set print on
    ? 'copy '+::tempfile+' prn'
    ? 'rem comando auxiliar de impresion'
    set print off
    set printer to
    waitrun('&cbat',0)
    erase &cbat
return


static function zoom(cOp)
 
if cop="+" .and. print_preview.edit_p.fontsize <= 24
  print_preview.edit_p.fontsize:=  print_preview.edit_p.fontsize + 2
endif

if cop="-" .and. print_preview.edit_p.fontsize > 7
  print_preview.edit_p.fontsize:=  print_preview.edit_p.fontsize - 2
endif
return nil


