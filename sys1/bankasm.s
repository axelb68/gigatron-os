
def scope():

    # int banktest(char *addr, char bitmask)
    # -- Check whether memory location <addr> changes
    #    when one twiddles the bit <bitmask> of the control word.

    # void _change_zbank(void)
    # -- Disable or enable zbank without crashing
    #    Do not call this until we know zbank is supported
    
    ctrlBits = 0x1f8

    addr  = 0x60
    ctrl0 = 0x62
    flag  = 0x63
    ctrl1 = 0x64
    sav0 =  0x66
    sav1 =  0x67

    def code0():
        nohop()
        label('_banktest')
        PUSH()
        LDW(R8);STW(addr)
        LDWI(ctrlBits);PEEK();_BEQ('.ret0')
        ST(ctrl0);XORW(R9);ST(ctrl1)
        LDWI('SYS_ExpanderControl_v4_40');STW('sysFn')
        LDI(0);ST(flag)
        # save
        _CALLJ('.b0');ST(sav0);LDI(0x55);POKE(addr)
        _CALLJ('.b1');ST(sav1);LDI(0xaa);POKE(addr)
        # test
        _CALLJ('.b0');XORI(0x55);LD(vACL);BEQ('.ok1');INC(flag);label('.ok1')
        _CALLJ('.b1');XORI(0xaa);LD(vACL);BEQ('.ok2');INC(flag);label('.ok2')
        # restore
        _CALLJ('.b1');LD(sav1);POKE(addr)
        _CALLJ('.b0');LD(sav0);POKE(addr)
        # return
        LD(flag);BEQ('.ret1')
        label('.ret0')
        LDI(0);POP();RET()
        label('.ret1')
        LDI(1);POP();RET()
        label('.b0')
        LD(ctrl0);SYS(40);LDW(addr);PEEK();RET()
        label('.b1')
        LD(ctrl1);SYS(40);LDW(addr);PEEK();RET()

    module(name='bankasm.s',
           code=[('EXPORT', '_banktest'),
                 ('CODE', '_banktest', code0),
                 ('PLACE', '_banktest', 0x0000, 0x7fff) ] )

    
scope()

# Local Variables:
# mode: python
# indent-tabs-mode: ()
# End:
