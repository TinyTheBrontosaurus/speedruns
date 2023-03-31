state("fceux64")
{
    byte _bosshp : 0x4D5150, 0x6C1;
    byte _mmhp : 0x4D5150, 0x6C0;
    byte _stage : 0x4D5150, 0x2A; //12 is boss rush, 13 is alien
    byte _mmxpos : 0x4D5150, 0x460;
    byte _mmypos :0x4D5150, 0x4A0;
    byte _screen : 0x4D5150, 0x1B;
}

init {
    print("Init");
    vars.state_machine = 0;
    vars.lastx = 500;
    vars.thisx = 500;
        
    vars.thisscreen = 500;
    vars.lastscreen = 500;
}

reset {
    // Don't reset if already reset
    if(vars.state_machine == 0) {
        return;
    } 
        
    // Start of Air Man level "Ready" blinking
    if((current._mmxpos == 128) && (vars.lastx == 0)) {
        print("Reset Air Man");
        vars.state_machine = 0;
        return true;
    }
}

update {
    vars.lastx = vars.thisx;
    vars.thisx = current._mmxpos;

    vars.lastscreen = vars.thisscreen;
    vars.thisscreen = current._screen;
    /*
    if( vars.lastscreen != vars.thisscreen) {
      print("screen: " + vars.lastscreen.ToString() + " " + vars.thisscreen.ToString());
    }*/
    
    return true;
}

start {
    if(vars.state_machine == 0) {
        if((vars.lastx == 0) && (current._mmxpos == 128)) {
            vars.state_machine++;
            print("Starting Air Man Level 1");
            return true;
        }
    }
}

split {
    if(vars.state_machine == 1) {
        if((vars.lastscreen == 2) && (current._screen == 128)) {
            vars.state_machine++;
            print("Starting Air Man Level 2");
            return true;
        }
    } else if(vars.state_machine == 2) {
        if((vars.lastscreen == 2) && (current._screen == 128)) {
            vars.state_machine++;
            print("Starting Air Man Level 3");
            return true;
        }
    } else if(vars.state_machine == 3) {
        if(current._bosshp > 0) {
            vars.state_machine++;
            print("Air Man energizing");
            return true;
        }
    } else if(vars.state_machine == 4) {
        if(current._bosshp == 0) {
            vars.state_machine++;
            print("Air Man defeated");
            return true;
        }
    }
    else {
        // No-op
    }
}

