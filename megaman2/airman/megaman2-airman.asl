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
    
    return true;
}

start {
    if(vars.state_machine == 0) {
        if((current._mmxpos == 128) && (vars.lastx == 0)) {
            vars.state_machine++;
            print("Starting Air Man Level 1");
            return true;
        }
    }
}

split {
    if(vars.state_machine == 1) {
        if((current._screen == 128) && (vars.lastscreen == 2)) {
            vars.state_machine++;
            print("Starting Air Man Level 2");
            return true;
        }
    } else if(vars.state_machine == 2) {
        if((current._screen == 128) && (vars.lastscreen == 2)) {
            vars.state_machine++;
            print("Starting Air Man Level 3");
            return true;
        }
    } else if(vars.state_machine == 3) {
        if((current._screen == 2) && (vars.lastscreen == 0)) {
            vars.state_machine++;
            print("Starting Air Man Gate 1 open");
        }
    } else if(vars.state_machine == 4) {
        if((current._screen == 2) && (vars.lastscreen == 0)) {
            vars.state_machine++;
            print("Starting Air Man Gate 1 close");
        }
    } else if(vars.state_machine == 5) {
        if((current._screen == 2) && (vars.lastscreen == 0)) {
            vars.state_machine++;
            print("Starting Air Man Boss open");
            return true;
        }
    } else if(vars.state_machine == 6) {
        if((current._screen == 2) && (vars.lastscreen == 0)) {
            vars.state_machine++;
            print("Starting Air Man Boss");
        }
    } else if(vars.state_machine == 7) {
        if(current._bosshp > 0) {
            vars.state_machine++;
            print("Air Man energizing");
        }
    } else if(vars.state_machine == 8) {
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

