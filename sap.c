 //Simple Audio Player
 // to compile:		gcc sap.cpp -lwinmm -o sap.exe
 
 #include <windows.h>
 #include <cstring>
 #include <stdio.h>
 
 int main(int argc, char** argv)
 {
 	if(argc!=2) { return 0; }
	
	//Build MCI command
	const char* open = "open \"";
	const char* alias = "\" alias snd";
	char * c;
	c = (char*)malloc(strlen(open)+strlen(argv[1])+strlen(alias)+1);
	strcpy(c, open);
	strcat(c, argv[1]);
	strcat(c, alias);
	int x = mciSendStringA(c, NULL, 0, 0);
	if(x>0) { return 1; }

	//Play
	const char* play = "play snd";
	x = mciSendStringA(play, NULL, 0, 0);
	if(x>0) { return 1; }

	//Wait for it to end
	const char* status = "status snd mode";
	char mcidata[129];
	int mcidatalen=sizeof(mcidata)-1;
	do {
		mciSendStringA(status,mcidata,mcidatalen,NULL);
	} while(stricmp(mcidata,"playing") == 0);

	return 0;
}