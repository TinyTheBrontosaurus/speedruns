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


startup {
    vars.boss = "Wily3";
    vars.levels = 9;
}

init {
    print("Init");
    vars.state_machine = 0;
    vars.lastx = 500;
    vars.thisx = 500;
        
    vars.thisscreen = 500;
    vars.lastscreen = 500;
    
    vars.isVerticalTransition = false;
}


update {
    vars.lastx = vars.thisx;
    vars.thisx = current._mmxpos;

    vars.lastscreen = vars.thisscreen;
    vars.thisscreen = current._screen;

    vars.mmAppeared = (vars.lastx == 0) && (current._mmxpos == 128);
    vars.isVerticalTransition = (vars.lastscreen == 2) && (current._screen == 128);
    
    return true;
}

reset {
    // Start level "Ready" blinking
    if(vars.mmAppeared) {
        print("Reset");
        vars.state_machine = 0;
        return true;
    }
}

start {
    if(vars.state_machine == 0) {
        if(vars.mmAppeared) {
            vars.state_machine++;
            print("Starting Level");
            return true;
        }
    }
}

split {
    
    if(vars.state_machine <= (vars.levels - 1)) {
        if(vars.isVerticalTransition) {
            print("Vertical transition count: " + vars.state_machine.ToString());
            vars.state_machine++;
            return true;
        }
    }
    
    // <= to deal with missed vertical transitions
    if(vars.state_machine <= vars.levels) {
        if(current._bosshp > 0) {
            vars.state_machine++;
            print(vars.boss + " energizing");
            return true;
        }
    } else if(vars.state_machine == (vars.levels + 1)) {  
        if(current._bosshp == 0) {
            vars.state_machine++;
            print(vars.boss + " defeated");
            return true;
        }   
    }
}

