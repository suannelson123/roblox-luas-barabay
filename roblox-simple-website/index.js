  AOS.init({
            duration: 800,
            easing: 'ease-in-out',
            once: true
        });
        
        VANTA.GLOBE({
            el: "#globe-container",
            mouseControls: true,
            touchControls: true,
            gyroControls: false,
            minHeight: 200.00,
            minWidth: 200.00,
            scale: 1.00,
            scaleMobile: 1.00,
            color: 0x9d50bb,
            backgroundColor: 0x6e48aa,
            size: 0.8
        });
        
        feather.replace();