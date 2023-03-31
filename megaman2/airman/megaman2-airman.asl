state("fceux64")
{
    byte _bosshp : 0x436B04, 0x6C1;
    byte _mmhp : 0x436B04, 0x6C0;
    byte _stage : 0x436B04, 0x2A; //12 is boss rush, 13 is alien
    ushort _mmxpos : 0x436B04, 0x460;
    ushort _mmypos :0x436B04, 0x4A0;
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
       (current._mmxpos == 61440) && (current._mmypos == 120)) {
        print("Reset Air Man");
        vars.state_machine = 0;
        return true;
    }
    
}

split {
    bool AtAirManLevel1() {
        return (current._stage == 1) && (current._mmxpos == 61568) && (current._mmypos == 116); 
    }

    bool AtAirManLevel2() {
        return (current._stage == 1) && (current._mmxpos == 61568) && (current._mmypos == 116);     
    }
    
    bool AtAirManLevel3() {
        return (current._stage == 1) && (current._mmxpos == 61568) && (current._mmypos == 116);         
    }
    
    bool AtAirManLevelBoss() {
        return (current._stage == 1) && (current._mmxpos == 61568) && (current._mmypos == 116);         
    }
    
    bool IsAirManDead() {
        return (current._stage == 1) && (current._mmxpos == 61568) && (current._mmypos == 116); 
        return current._bosshp == 0;
    }
    
    
    if(vars.state_machine == 0) {
        if(AtAirManLevel1()) {
            vars.state_machine++;
            print("Starting Air Man Level 1");
            return true;
        }
    } else if(vars.state_machine == 1) {
        if(AtAirManLevel2()) {
            vars.state_machine++;
            print("Starting Air Man Level 2");
            return true;
        }
    } else if(vars.state_machine == 2) {
        if(AtAirManLevel3()) {
            vars.state_machine++;
            print("Starting Air Man Level 3");
            return true;
        }
    } else if(vars.state_machine == 3) {
        if(AtAirManBoss()) {
            vars.state_machine++;
            print("Starting Air Man Boss");
            return true;
        }
    } else if(vars.state_machine == 4) {
        if(IsAirManDead()) {
            vars.state_machine++;
            print("Air Man defeated");
            return true;
        }
    }
    else {
        // No-op
    }

}

