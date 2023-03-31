/**
 *  Auto splitter that simply counts the number of vertical transitions
 *
 */



state("fceux64", "2.3.5")
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
    
    vars.IsVerticalTransition = () => (vars.lastscreen == 2) && (current._screen == 128);
}

reset {
    // Don't reset if already reset
    if(vars.state_machine == 0) {
        return;
    } 
        
    // Start of Air Man level "Ready" blinking
    if((current._mmxpos == 128) && (vars.lastx == 0)) {
        print("Reset");
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
        if((vars.lastx == 0) && (current._mmxpos == 128)) {
            vars.state_machine++;
            print("Starting Level");
            return true;
        }
    }
}

split {
    if(vars.IsVerticalTransition()) {
        vars.state_machine++;
        print("Vertical transition count: " + vars.state_machines.ToString());
    }
}

