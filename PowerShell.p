unit Power;
interface
	uses
		Sound, QDOffScreen, Globals, Tools, Game, GameTools,
		Resources ,Menus, Dialogs;
	procedure PowerShell;	
	procedure HandlePSClick(Hit:point;var reply:integer);
	procedure PSUpdate;
	procedure PSAbout;
	procedure PSHelp;
	


implementation
	const
		RollConst = 0;
		RollInConst = 73-56;
		Plate1 = 85-56;
		Plate2 = 90-56;
		Plate3 = 95-56;
		Done = 100-56;

	var
		PState, TState,TSize: integer;
		ScrollText:Handle;
		PGWorld: GWorldPtr;
		raceTLpt,oldTLpt:Point;


	
		procedure GWorldInitPic;			
			var
				DrawingRect:Rect;
				oldG:GWorldPtr;
				oldD:GDHandle;
		begin
			GetGworld(oldG,oldD);
			SetRect(DrawingRect,0,0,200*2,92);
			DoError(NewGWorld(PGworld,0,DrawingRect,nil,nil,0));
			SetGWorld(PGWorld,nil);
			SetRect(DrawingRect,0,0,200,92);
			DrawPicture(GetPicture(2010), DrawingRect);
			SetRect(DrawingRect,200,0,200*2,92);
			DrawPicture(GetPicture(2011), DrawingRect);
			SetGWorld(oldG,oldD);
		end;
	
		procedure drawRACE(ou:point;var old:point;win:WindowPtr);
			var
				scr,DrawingRect:Rect;
		begin
			SetRect(scr,200,0,200*2,92);
			if old.h<ou.h then
				SetRect(DrawingRect,old.h,old.v,ou.h,old.v+92)
			else
				SetRect(DrawingRect,old.h,ou.v+92,old.h+200,old.v+92);
			FillRect(DrawingRect,qd.black);				
			SetRect(DrawingRect,ou.h,ou.v,200+ou.h,92+ou.v);
			CopyBits(BitMapHandle(GetGWorldPixMap(PGworld))^^, win^.portbits, scr, DrawingRect, srcCopy, nil);
			old:=ou;
		end;
		
		procedure drawSPEED(ou:point;var old:point;win:WindowPtr);
			var
				scr,DrawingRect:Rect;
		begin
			SetRect(scr,0,0,200,92);
			if old.h<ou.h then
				SetRect(DrawingRect,old.h,old.v,ou.h,old.v+92)
			else
				SetRect(DrawingRect,old.h,ou.v+92,old.h+200,old.v+92);
			FillRect(DrawingRect,qd.black);		
			SetRect(DrawingRect,ou.h,ou.v,200+ou.h,92+ou.v);
			CopyBits(BitMapHandle(GetGWorldPixMap(PGworld))^^, win^.portbits, scr, DrawingRect, srcCopy, nil);
			old:=ou;
		end;
		
		

	procedure PowerPlay;
		var 
			DrawingRect:rect;			
	begin
		if PState = RollConst then
			begin
				SetPt(raceTLpt, -45, 10);
				oldTLpt:=raceTLpt;
				PlaySound(3001);
				GWorldInitPic;
			end
		else if Pstate < RollInConst then
			begin
				drawSPEED(raceTLpt,oldTLpt,ShellWindow);
				OffsetPt(raceTLpt,13,0);
			end
		else if PState = RollInConst then
			begin				
				DrawRACE(raceTLpt,oldTLpt,ShellWindow);
				DisposeGWorld(PgWorld);
				EnableItem(AppleMenu,1);
			end;
		if PState <= Plate3 then
			begin
				if Pstate = Plate1 then
					begin
						SetRect(Drawingrect, 21, 237, 106, 278);
						drawpicture(getpicture(2020), DrawingRect);
						PlaySound(3002);
					end;
				if Pstate = Plate2 then
					begin
						SetRect(Drawingrect, 214, 237, 299, 278);
						drawpicture(getpicture(2021), DrawingRect);
						PlaySound(3002);
					end;
				if Pstate = Plate3 then
					begin
						SetRect(Drawingrect, 407, 237, 491, 278);
						drawpicture(getpicture(2022), DrawingRect);
						PlaySound(3002);
						MoveTo(15,295);
						TextFont(0);
						TextSize(12);
						BackColor(WhiteColor);
						TextMode(srcBic);
						DrawString(GetString(1000)^^);
					end;
			end;
		
		
		if PState = Done then 
			begin
				TextFont(201);
				TextSize(34);
				TextMode(notSrcCopy);
				BackColor(Redcolor);
				if ScrollText = nil then
					ScrollText:= GetResource('TEXT',1000);
				if TSize=0 then
					TSize:=TextWidth(ScrollText^,0,GetHandleSize(Scrolltext));
				if TState<0 then
					TState:=TState+TSize;
				if TState>TSize then
					TState:=TState-TSize;
				MoveTo(0-TState,200);
				DrawText(ScrollText^,0,GetHandleSize(Scrolltext));
				TState:=TState+15;
			end;	
		if PState <> Done then
			PState := PState + 1;
	end;

	procedure HandlePSClick(Hit:point;var reply:integer);
	var
		InRect:Rect;
	begin 	
	reply:= 0;
	if PState = Done then 
		begin
			SetRect(InRect, 21, 237, 106, 278);
			if PtInRect(Hit,InRect) then
				begin
					DrawPicture(GetPicture(3020),InRect);
					ReleaseResource(GetResource('PICT',3020));
					while Stilldown do;
					GetMouse(Hit);
					if PtInRect(Hit,InRect) then
						reply:=1;					
					DrawPicture(GetPicture(2020),InRect);
					Exit(HandlePSClick);
				end;
	
			SetRect(InRect, 214, 237, 299, 278);
			if PtInRect(Hit,InRect) then
				begin
					DrawPicture(GetPicture(3021),InRect);
					ReleaseResource(GetResource('PICT',3021));
					while Stilldown do;
					GetMouse(Hit);
					if PtInRect(Hit,InRect) then
						reply:=2;
					DrawPicture(GetPicture(2021),InRect);
					Exit(HandlePSClick);
				end;	
				
			SetRect(InRect, 407, 237, 491, 278);
			if PtInRect(Hit,InRect) then
				begin
					DrawPicture(GetPicture(3022),InRect);
					ReleaseResource(GetResource('PICT',3022));
					while Stilldown do;
					GetMouse(Hit);
					if PtInRect(Hit,InRect) then
						reply:=3;
					DrawPicture(GetPicture(2022),InRect);
				end;		
			end;
	end;
	
	
	procedure PSUpdate;
		var
			Drawingrect:Rect;
	begin 
		BeginUpdate(ShellWindow);
		SetPort(ShellWindow);
		if PState >= RollInConst then
			begin
				SetRect(DrawingRect, 163, 10, 163+200, 102);
				DrawPicture(GetPicture(2011), DrawingRect);
			end;
		if PState >= Plate1 then 
			begin
				SetRect(Drawingrect, 21, 237, 106, 278);
				drawpicture(getpicture(2020), DrawingRect);
			end;
		if PState >= Plate2 then 
			begin
				SetRect(Drawingrect, 214, 237, 299, 278);
				drawpicture(getpicture(2021), DrawingRect);
			end;
		if PState >= Plate3 then 
			begin	
				SetRect(Drawingrect, 407, 237, 491, 278);
				drawpicture(getpicture(2022), DrawingRect);
				MoveTo(15,295);
				TextFont(0);
				TextSize(12);
				BackColor(WhiteColor);
				TextMode(srcBic);
				DrawString(GetString(1000)^^);
			end;	
		EndUpdate(ShellWindow);
	end;
	
	procedure PowerShell;
		var
			time: longint;
	begin
		if not GamePlay then
			begin
				SetGWorld(CGrafPtr(ShellWindow), TheScreen);
				time := tickcount;
				PowerPlay;
				if PState <> Done then
					while tickcount<time  + 2 do
				else
					while tickcount<time  + 2 do;
			end
		else 
				PState := Done;
	end;
	
	
	
	
	procedure PSAbout;
		const SpeedStop=169;
		var 
			AboutDlg:DialogPtr;
			hit:integer;
			Ticky:longint;
			DrawingRect:Rect;
	begin
		AboutDlg:=GetNewDialog(2005,nil,Pointer(-1));
		DoError(SetDialogDefaultItem(AboutDlg, 1));
		SetPt(RaceTLpt,-52,12);
		oldTLpt:=RaceTLpt;
		SetPort(AboutDlg);
		SetRect(DrawingRect,0,0,360,157);
		FillRect(DrawingRect,qd.black);
		SetRect(DrawingRect,0,157,222,190);
		FillRect(DrawingRect,qd.black);
		GWorldInitPic;
		repeat
			Ticky:=TickCount;
			OffSetPt(RaceTLpt,13,0);	
			DrawSPEED(RaceTLpt,oldTLpt,AboutDlg);
			Delay(Ticky-TickCount+2,Ticky);
		until RaceTLpt.h = SpeedStop;
		DrawRACE(RaceTLpt,oldTLpt,AboutDlg);	
		SetRect(DrawingRect,-3,0,360,190);
		PlaySound(3000);
		DrawPicture(GetPicture(1101),DrawingRect);
		ReleaseResource(GetResource('PICT',1101));
		repeat
			ModalDialog(nil,hit);
		until (hit=1) or (hit=2);
		DisposeDialog(AboutDlg);
		DisposeGWorld(PGWorld);
		if hit=2 then
			PSHelp;
	end;
	
	procedure PSHelp;
		var
		 DrawingRect:Rect;
	begin
			SetGWorld(CGrafPtr(ShellWindow), TheScreen);
			SetRect(DrawingRect,0,0,513,301);
			DrawPicture(GetPicture(1100),DrawingRect);
			ReleaseResource(GetResource('PICT',1100));
			repeat until button;
			FillRect(DrawingRect,qd.black);
			InvalRect(DrawingRect);
			PSUpdate;
	end;
		
end.