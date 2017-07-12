      program koi87track
      implicit none
      integer nunit,nmax,i,dumi,npt,j
      parameter(nmax=151)
      real Tsun, Pi, Rsun, Msun,dumr,logL,Teff(nmax),rhostar(nmax),G,
     .  trad,Ms,Rs,px(5),py(5),errxp(3),errxm(3),erryp(3),errym(3),M(4),
     .  logg(nmax)
      character*80 filename(4),dumc

      Tsun=5781.6e0 !Solar temperature (K)
      Pi=acos(-1.e0)!define Pi and 2*Pi
      Rsun=696265.0e0*1000.0e0 !m  radius of Sun
      Msun=1.9891e30 !kg  mass of Sun
      G=6.67259E-11
      
      call pgopen('?')
      call pgpage()
      call PGPAP ( 6.0 ,1.0)  
      call pgvport(0.15,0.85,0.2,0.9)
c      call PGENV ( -0.5 , 0.5 , -0.5 , 0.5 , 1 , -2 )  
      call pgwindow(6000.0,5000.0,4.8,4.0)
      call pgslw(3)
      call pgsch(1.5)
      CALL PGBOX('BCNTS1',0.0,0,'BCNTS1',0.0,0)
      call pglabel("T\deff\u (K)",
     .  "log(g)","")
     
      nunit=10
c      filename(1)="m07x74z01.track2"
c      filename(2)="m08x74z01.track2"
c      filename(3)="m09x74z01.track2"
c      filename(4)="m10x74z01.track2"
      filename(1)="m07x71z02.track2"
      filename(2)="m08x71z02.track2"
      filename(3)="m09x71z02.track2"
      filename(4)="m10x71z02.track2"
      M(1)=0.7
      M(2)=0.8
      M(3)=0.9
      M(4)=1.0
      
      do 13 j=1,4
        open(unit=nunit,file=filename(j),status='old',err=901)
      
        do 10 i=1,11
            read(nunit,*) dumc
 10     continue
      
        Ms=M(j)*Msun
        i=1
 11     read(nunit,*,end=12) dumi,dumr,Teff(i),logL
            Teff(i)=10.0**(Teff(i))
            trad=sqrt( (Tsun/Teff(i))**4.0e0*10.0e0**logL )
            Rs=trad*Rsun
            rhostar(i)=Ms/(4.0d0/3.0d0*pi*Rs*Rs*Rs)/1000.0d0
c            write(0,*) i,Teff(i),rhostar(i)
            logg(i)=log10(G*Ms/(Rs*Rs))+2.0
            i=i+1
        goto 11     
 12     continue
        npt=i-1
      
        close(nunit)
        
        call pgsci(j+1)
        call pgline(npt,Teff,logg)
 13   continue
      call pgsci(1)
      
      errxp(1)=100.0
      errxm(1)=100.0
      errxp(2)=200.0
      errxm(2)=200.0
      errxp(3)=300.0
      errxm(3)=300.0
      erryp(1)=0.1
      errym(1)=0.1
      erryp(2)=0.2
      errym(2)=0.2
      erryp(3)=0.3
      errym(3)=0.3
      
      do 15 j=1,3
        px(1)=5510.0-errxm(j)
        px(2)=5510.0+errxp(j)
        px(3)=px(2)
        px(4)=px(1)
        px(5)=px(1)

        py(1)=4.4-errym(j)
        py(2)=py(1)
        py(3)=4.4+erryp(j)
        py(4)=py(3)
        py(5)=py(1)
      
c      do 14 i=1,5
c        write(0,*) px(i),py(i)     
c 14   continue
      
        call pgline(5,px,py)

15    continue
      call pgsci(1)
      call pgpt1(Tsun,4.44,9)

      call pgclos()

      goto 999
 901  write(0,*) "Cannot open ",filename
      goto 999
 999  end