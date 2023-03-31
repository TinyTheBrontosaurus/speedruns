state("fceux64")
{
    byte _bosshp : 0x4D5150, 0x6C1;
    byte _mmhp : 0x4D5150, 0x6C0;
    byte _stage : 0x4D5150, 0x2A; //12 is boss rush, 13 is alien
    ushort _mmxpos : 0x4D5150, 0x460;
    ushort _mmypos :0x4D5150, 0x4A0;
}

init {
    print("Init");
    vars.state_machine = 0;
}

reset {
    // Don't reset if already reset
    if(vars.state_machine == 0) {
        return;
    } 
        
    // Start of Air Man level "Ready" blinking
    if((current._stage == 1) && 
       (current._mmxpos == 61440) && (current._mmypos == 10360)) {
        print("Reset Air Man");
        vars.state_machine = 0;
        return true;
    }
}

start {
    if(vars.state_machine == 0) {
        if((current._stage == 1) && (current._mmxpos == 61568) && (current._mmypos == 10356)) {
            vars.state_machine++;
            print("Starting Air Man Level 1");
            return true;
        }
    }
}

split {
    if(vars.state_machine == 1) {
        if((current._stage == 1) && (current._mmxpos == 61575) && (current._mmypos == 10356)) {
            vars.state_machine++;
            print("Starting Air Man Level 2");
            return true;
        }
    } else if(vars.state_machine == 2) {
        if((current._stage == 1) && (current._mmxpos == 61600) && (current._mmypos == 10356)) {
            vars.state_machine++;
            print("Starting Air Man Level 3");
            return true;
        }
    } else if(vars.state_machine == 3) {
        if((current._stage == 1) && (current._mmxpos == 61668) && (current._mmypos == 10356)) {
            vars.state_machine++;
            print("Starting Air Man Boss");
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

