CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      subroutine mcmc(npta,aT,aM,aE,aIT,dtype,nfit,sol,sol2,serr,tmodel,
     .  rchi,seed,flag,bchi,ng,dil,ndmp,mdmp,rdmp)
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      implicit none
      integer npta,nfit,i,seed,flag,ng,ndmp,ntry,ntrymax
      integer dtype(npta)
      double precision aT(npta),aM(npta),aE(npta),sol(nfit),aIT(npta),
     .  serr(nfit,2),tmodel(npta),sol2(nfit),rchi,ran2,chi1,chi2,
     .  fratio,u,alpha,bchi,gasdev,dil(2),mdmp(ndmp),rdmp(ndmp),
     .  jitter(2),jrv,jrvp(2),rgas
     
      jitter(1)=2.5 !m/s RV stellar jitter
      jitter(2)=1.0 !m/s RV stellar jitter float
C     reformalize jitters for log scale
      jrvp(1)=log(jitter(1))
      jrvp(2)=(log((jitter(1)+jitter(2))/jitter(1)))**2.0d0
      jrv=0.0d0 !default value of jitter.
  
      do 16 i=1,nfit
        sol2(i)=sol(i)
  16  continue
  
      ntry=0
      ntrymax=500
  15  ng=int(ran2(seed)*dble(nfit-1)+1.0d0)
      if((ng.lt.1).or.(ng.gt.nfit-1)) goto 15 !make sure we have a valid i
      if(serr(ng,2).eq.0.0d0) goto 15 !if sig is zero we don't change
  18  if((ng.eq.1).or.(ng.eq.3).or.(ng.eq.4).or.(ng.eq.6))then
        i=int(ran2(seed)*dble(ndmp-1)+1.0d0)
c        if(ntry.eq.0)then
            sol2(1)=mdmp(i)!gasdev(seed)*serr(1,2)+sol(1)
            sol2(3)=rdmp(i)!gasdev(seed)*serr(3,2)+sol(3)
c        endif
        sol2(4)=sol2(3)*(sol(4)/sol(3)+gasdev(seed)*serr(4,2))
        sol2(6)=gasdev(seed)*serr(6,2)+sol(6)
        ntry=ntry+1
c        sol2(6)=sol2(4)/sol2(3)*(sol(6)/(sol(4)/sol(3))+
c     .      gasdev(seed)*serr(6,2))
c        sol2(6)=91.9948d0-5.35116d0*sol2(3)+gasdev(seed)*serr(6,2)
      elseif(ng.eq.2)then
        sol2(2)=gasdev(seed)*serr(2,2)+sol(2)
c      elseif(ng.eq.4)then
c        sol2(4)=gasdev(seed)*serr(4,2)+sol(4)
c         sol2(4)=sol2(3)*(sol(4)/sol(3)+gasdev(seed)*serr(4,2))
      elseif(ng.eq.5)then
        sol2(5)=gasdev(seed)*serr(5,2)+sol(5)
c      elseif(ng.eq.6)then
c        sol2(6)=gasdev(seed)*serr(6,2)+sol(6)
c        sol2(6)=sol2(4)/sol2(3)*(sol(6)/(sol(4)/sol(3))+
c     .      gasdev(seed)*serr(6,2))
      elseif(ng.eq.7)then
        sol2(7)=gasdev(seed)*serr(7,2)+sol(7)
      elseif(ng.eq.8)then
        sol2(8)=gasdev(seed)*serr(8,2)+sol(8)
      elseif(ng.eq.9)then
        sol2(9)=gasdev(seed)*serr(9,2)+sol(9)
      elseif(ng.eq.10)then
        sol2(10)=gasdev(seed)*serr(10,2)+sol(10)
      elseif(ng.eq.11)then
        sol2(11)=gasdev(seed)*serr(11,2)+sol(11)
      elseif(ng.eq.12)then
        sol2(12)=gasdev(seed)*serr(12,2)+sol(12)
      elseif(ng.eq.13)then
        sol2(13)=gasdev(seed)*serr(13,2)+sol(13)
      elseif(ng.eq.14)then
        sol2(14)=gasdev(seed)*serr(14,2)+sol(14)
      elseif(ng.eq.15)then
        sol2(15)=gasdev(seed)*serr(15,2)+sol(15)
      elseif(ng.eq.16)then
        sol2(16)=gasdev(seed)*serr(16,2)+sol(16)
      elseif(ng.eq.17)then
        sol2(17)=gasdev(seed)*serr(17,2)+sol(17)
      endif
      if((sol2(6).gt.90.0d0).and.(ntry.ge.ntrymax)) then
        flag=1
        return
      elseif((sol2(6).gt.90.0d0).and.(ntry.lt.ntrymax)) then
        goto 18
      endif
      if(sol2(3).lt.0.0d0) then !was sol(3).lt.0.0d0
        flag=1
        return
      endif
C     Shuffle dilution with Gaussian for every chain element
 17   sol2(18)=gasdev(seed)*dil(2)+dil(1)
      if(sol2(18).lt.0.0d0) goto 17
      if(jitter(2).gt.0.0d0)then
        rgas=gasdev(seed)
        jrv=exp(rgas*jrvp(2)+jrvp(1))
c        write(0,*) "jrv",jrv,rgas*jitter(2)+jitter(1)
c        read(5,*)
      endif
      
C     Get chi-squared for both models
      call transitmodel(npta,aT,aIT,dtype,tmodel,nfit,sol)
      chi1=0.0d0
      do 11 i=1,npta
        if(dtype(i).eq.1)then
            chi1=chi1+(aM(i)-tmodel(i))*(aM(i)-tmodel(i))/(aE(i)*aE(i)+
     .          jrv*jrv)
        else
            chi1=chi1+(aM(i)-tmodel(i))*(aM(i)-tmodel(i))/(aE(i)*aE(i))
        endif
c        chi1=chi1+(aM(i)-tmodel(i))*(aM(i)-tmodel(i))/tmodel(i)
 11   continue
      chi1=chi1*bchi
 
      call transitmodel(npta,aT,aIT,dtype,tmodel,nfit,sol2)
      chi2=0.0d0
      do 12 i=1,npta
        if(dtype(i).eq.1)then
            chi2=chi2+(aM(i)-tmodel(i))*(aM(i)-tmodel(i))/(aE(i)*aE(i)+
     .          jrv*jrv)
        else
            chi2=chi2+(aM(i)-tmodel(i))*(aM(i)-tmodel(i))/(aE(i)*aE(i))
        endif
c        chi2=chi2+(aM(i)-tmodel(i))*(aM(i)-tmodel(i))/tmodel(i)
c        write(0,*) aM(i),tmodel(i)
 12   continue
      chi2=chi2*bchi
 
      fratio=exp(0.5d0*(chi1-chi2))
      u=ran2(seed)
      alpha=min(fratio,1.0d0)
      if(u.le.alpha)then
        flag=0
        rchi=chi2
      else
        flag=1
        rchi=chi1
      endif
      if((ng.eq.1).or.(ng.eq.3).or.(ng.eq.4).or.(ng.eq.6))then
c        write(0,*) "ntry:",ntry,sol2(6),fratio
        if((flag.eq.1).and.(ntry.lt.ntrymax)) goto 18
      endif
c      write(0,*) flag,fratio,u
c      write(0,*) alpha,chi1,chi2
c      write(0,*) sol2(7),sol2(8),ng
c      write(0,*) sol2(1),sol2(3),sol2(4)
c      write(0,*) sol2(6)
c      read(5,*)
     
      return
      end
