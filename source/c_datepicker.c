/*
 * $Id: c_datepicker.c,v 1.6 2007-01-01 20:52:13 guerra000 Exp $
 */
/*
 * ooHG source code:
 * C date picker functions
 *
 * Copyright 2005 Vicente Guerra <vicente@guerra.com.mx>
 * www - http://www.guerra.com.mx
 *
 * Portions of this code are copyrighted by the Harbour MiniGUI library.
 * Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the ooHG Project gives permission for
 * additional uses of the text contained in its release of ooHG.
 *
 * The exception is that, if you link the ooHG libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the ooHG library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the ooHG
 * Project under the name ooHG. If you copy code from other
 * ooHG Project or Free Software Foundation releases into a copy of
 * ooHG, as the General Public License permits, the exception does
 * not apply to the code that you add in this way. To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for ooHG, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */
/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
 http://www.geocities.com/harbour_minigui/

 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 this software; see the file COPYING. If not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text
 contained in this release of Harbour Minigui.

 The exception is that, if you link the Harbour Minigui library with other
 files to produce an executable, this does not by itself cause the resulting
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the
 Harbour-Minigui library code into it.

 Parts of this project are based upon:

	"Harbour GUI framework for Win32"
 	Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - http://www.harbour-project.org

	"Harbour Project"
	Copyright 1999-2003, http://www.harbour-project.org/
---------------------------------------------------------------------------*/


#define _WIN32_IE      0x0500
#define HB_OS_WIN_32_USED
#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include "winreg.h"
#include "tchar.h"
#include "../include/oohg.h"

static WNDPROC lpfnOldWndProcA = 0;
static WNDPROC lpfnOldWndProcB = 0;

static LRESULT APIENTRY SubClassFuncA( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   return _OOHG_WndProcCtrl( hWnd, msg, wParam, lParam, lpfnOldWndProcA );
}

static LRESULT APIENTRY SubClassFuncB( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   return _OOHG_WndProcCtrl( hWnd, msg, wParam, lParam, lpfnOldWndProcB );
}

HB_FUNC( INITDATEPICK )
{
   HWND hwnd;
   HWND hbutton;
   int Style = WS_CHILD;
   int StyleEx;

	INITCOMMONCONTROLSEX  i;
	i.dwSize = sizeof(INITCOMMONCONTROLSEX);
	i.dwICC = ICC_DATE_CLASSES;
	InitCommonControlsEx(&i);

   hwnd = HWNDparam( 1 );

   StyleEx = WS_EX_CLIENTEDGE | _OOHG_RTL_Status( hb_parl( 14 ) );

	if ( hb_parl (9) )
	{
		Style = Style | DTS_SHOWNONE ;
	}

	if ( hb_parl (10) )
	{
		Style = Style | DTS_UPDOWN ;
	}

	if ( hb_parl (11) )
	{
		Style = Style | DTS_RIGHTALIGN ;
	}

	if ( ! hb_parl (12) )
	{
		Style = Style | WS_VISIBLE ;
	}

	if ( ! hb_parl (13) )
	{
		Style = Style | WS_TABSTOP ;
	}

    hbutton = CreateWindowEx( StyleEx, "SysDateTimePick32", 0,
	Style ,
	hb_parni(3), hb_parni(4) ,hb_parni(5) ,hb_parni(6) ,
	hwnd,(HMENU)hb_parni(2) , GetModuleHandle(NULL) , NULL ) ;

   lpfnOldWndProcA = ( WNDPROC ) SetWindowLong( ( HWND ) hbutton, GWL_WNDPROC, ( LONG ) SubClassFuncA );

   HWNDret( hbutton );
}

HB_FUNC ( SETDATEPICK )
{
	HWND hwnd;
	SYSTEMTIME sysTime;
	int y;
	int m;
	int d;

        hwnd = HWNDparam( 1 );

	y = hb_parni(2);
	m = hb_parni(3);
	d = hb_parni(4);

	sysTime.wYear = y;
	sysTime.wMonth = m;
	sysTime.wDay = d;
	sysTime.wDayOfWeek = 0;

	sysTime.wHour = 0;
	sysTime.wMinute = 0;
	sysTime.wSecond = 0;
	sysTime.wMilliseconds = 0;

	SendMessage(hwnd, DTM_SETSYSTEMTIME,GDT_VALID, (LPARAM) &sysTime);
}

HB_FUNC ( GETDATEPICKYEAR )
{
	HWND hwnd;
	SYSTEMTIME st;
        hwnd = HWNDparam( 1 );

	SendMessage(hwnd, DTM_GETSYSTEMTIME, 0, (LPARAM) &st);
	hb_retni(st.wYear);
}

HB_FUNC ( GETDATEPICKMONTH )
{
	HWND hwnd;
	SYSTEMTIME st;
        hwnd = HWNDparam( 1 );

	SendMessage(hwnd, DTM_GETSYSTEMTIME, 0, (LPARAM) &st);
	hb_retni(st.wMonth);
}

HB_FUNC ( GETDATEPICKDAY )
{
	HWND hwnd;
	SYSTEMTIME st;
        hwnd = HWNDparam( 1 );

	SendMessage(hwnd, DTM_GETSYSTEMTIME, 0, (LPARAM) &st);
	hb_retni(st.wDay);
}

HB_FUNC ( SETDATEPICKNULL )
{
	HWND hwnd;

        hwnd = HWNDparam( 1 );

	SendMessage(hwnd, DTM_SETSYSTEMTIME,GDT_NONE, (LPARAM) 0 );
}

HB_FUNC( INITTIMEPICK )
{
   HWND hwnd;
   HWND hbutton;
   int Style = WS_CHILD ;

   INITCOMMONCONTROLSEX  i;
   i.dwSize = sizeof(INITCOMMONCONTROLSEX);
   i.dwICC = ICC_DATE_CLASSES;
   InitCommonControlsEx(&i);

   hwnd = HWNDparam( 1 );

   if ( hb_parl (9) )
   {
      Style = Style | DTS_SHOWNONE ;
   }

     Style = Style | DTS_TIMEFORMAT ;

     Style = Style | DTS_UPDOWN ;

   if ( ! hb_parl (10) )
   {
      Style = Style | WS_VISIBLE ;
   }

   if ( ! hb_parl (11) )
   {
      Style = Style | WS_TABSTOP ;
   }
   hbutton = CreateWindowEx(WS_EX_CLIENTEDGE,DATETIMEPICK_CLASS,"DateTime",
   Style ,
   hb_parni(3), hb_parni(4) ,hb_parni(5) ,hb_parni(6) ,
   hwnd,(HMENU)hb_parni(2) , GetModuleHandle(NULL) , NULL ) ;

   lpfnOldWndProcB = ( WNDPROC ) SetWindowLong( ( HWND ) hbutton, GWL_WNDPROC, ( LONG ) SubClassFuncB );

   HWNDret( hbutton );
}

HB_FUNC ( SETTIMEPICK )
{
   HWND hwnd;
   SYSTEMTIME sysTime;
   int h;
   int m;
   int s;

   hwnd = HWNDparam( 1 );

   h = hb_parni(2);
   m = hb_parni(3);
   s = hb_parni(4);

   sysTime.wYear = 2005;
   sysTime.wMonth = 1;
   sysTime.wDay = 1;
   sysTime.wDayOfWeek = 0;

   sysTime.wHour = h;
   sysTime.wMinute = m;
   sysTime.wSecond = s;
   sysTime.wMilliseconds = 0;

   SendMessage(hwnd, DTM_SETSYSTEMTIME,GDT_VALID, (LPARAM) &sysTime);
}

HB_FUNC ( GETDATEPICKHOUR )
{
   SYSTEMTIME st;

   if( SendMessage( HWNDparam( 1 ), DTM_GETSYSTEMTIME, 0, (LPARAM) &st)==GDT_VALID)
   {
      hb_retni(st.wHour);
   }
   else
   {
     hb_retni(-1);
   }
}

HB_FUNC ( GETDATEPICKMINUTE )
{
   SYSTEMTIME st;

   if( SendMessage( HWNDparam( 1 ), DTM_GETSYSTEMTIME, 0, (LPARAM) &st)==GDT_VALID ) {
   hb_retni(st.wMinute);
   }
   else
   {
     hb_retni(-1);
   }
}

HB_FUNC ( GETDATEPICKSECOND )
{
   SYSTEMTIME st;

   if( SendMessage( HWNDparam( 1 ), DTM_GETSYSTEMTIME, 0, (LPARAM) &st)==GDT_VALID )
   {
      hb_retni(st.wSecond);
   }
   else
   {
      hb_retni(-1);
   }
}
