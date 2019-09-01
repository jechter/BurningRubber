unit Globals;
interface
	uses
		Sound,
		Windows, Menus, QDOffScreen;
	type
		Preferences = record
				Width, Height: integer;
				GrafFlags: byte;
				TextureSize, Speed, X: integer;
				Offset: integer;
			end;
		PrefPtr = ^Preferences;
		PrefHandle = ^PrefPtr;


		Keys = record
				AccCode, BrakCode, LCode, RCode: integer;
			end;
		KeyPtr = ^Keys;
		KeyHandle = ^KeyPtr;
		
		
		ScoreEntry=record
			Score:longint;
			Name:string;
		end;
		ScorePtr=^ScoreEntry;
		ScoreHandle=^ScorePtr;



	var
		ShellWindow, RaceWindow: WindowPtr;
		AppleMenu, FileMenu, OptMenu: MenuHandle;
		GamePlay,GamePause: boolean;
		GamePrefs: PrefHandle;
		GameKeys: KeyHandle;
		CarID, Level: integer;
		TheScreen: GDHandle;
		EngineChannel, EffectAChannel, EffectBChannel: SndChannelPtr;
		ErrFlags: byte;
		CTOrig,Depth,OldDepth: integer;
		SoundDisable: boolean;
		Cheater:boolean;
		Sb,Sf:RgbColor;
	


implementation
end.