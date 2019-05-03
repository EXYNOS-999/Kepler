subroutine fittransitmodel(nbodies,npt,tol,sol,serr,time,flux,ferr,itime)
use precision
use fittingmod
implicit none
integer npt,n,i,info,lwa,j
integer, target :: nbodies
integer, allocatable, dimension(:) :: iwa
real(double), target :: tol,tollm
real(double), dimension(:), target :: sol,time,flux,ferr,itime
real(double), dimension(:,:), target :: serr
real(double), allocatable, dimension(:) :: solfit,wa,fvec
external fcn

allocate(solfit(7+nbodies*7))

!how many variables are we fitting?
n=0
do i=1,7+nbodies*7
   if(serr(i,2).ne.0.0d0)then
      n=n+1
      solfit(n)=sol(i)
   endif
enddo
write(0,*) "n:",n

!assign pointers from module that is shared with FCN
tol2 => tol
nbodies2 => nbodies
sol2 => sol
serr2 => serr
time2 => time
flux2 => flux
ferr2 => ferr
itime2 => itime

lwa=npt*n+5*npt*n
allocate(fvec(npt),iwa(n),wa(lwa))
tollm=1.0d-12
!!call lmdif1(fcn,m,n,x,fvec,tollm,info,iwa,wa,lwa)
write(0,*) "Calling lmdif1"
call lmdif1(fcn,npt,n,solfit,fvec,tollm,info,iwa,wa,lwa)
write(0,*) "info: ",info

n=0
do i=1,7+nbodies*7
   if(serr(i,2).ne.0.0d0)then
      n=n+1
      sol(i)=solfit(n)
      write(0,*) "out:",sol(i),solfit(n)
   endif
enddo

return
end subroutine fittransitmodel

!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
subroutine fcn(npt,n,x,fvec,iflag)
!CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
use precision
use fittingmod
implicit none
!import vars
integer :: npt,n,iflag
real(double), dimension(n) :: x
real(double), dimension(npt) :: fvec
!local vars
integer :: i,j,nunit,itprint,itmodel
real(double) :: yp
real(double), allocatable, dimension(:) :: sol3,m3,y3,percor
!percorcalc
integer :: npt3
real(double) :: tsamp,ts,te
real(double), allocatable, dimension(:) :: time3,itime3,ans3

interface
   subroutine lcmodel(nbodies,npt,tol,sol,time,itime,percor,ans,itprint,itmodel)
      use precision
      implicit none
      integer, intent(inout), target :: nbodies
      integer, intent(inout) :: npt,itprint,itmodel
      real(double), intent(inout) :: tol
      real(double), dimension(:), intent(inout) :: sol,time,itime,percor
      real(double), dimension(:), intent(inout) :: ans
   end subroutine lcmodel
   subroutine percorcalc(nbodies,sol,percor)
      use precision
      use ocmod
      implicit none
      !import vars
      integer, intent(in) :: nbodies
      real(double), dimension(:), intent(in) :: sol
      real(double), dimension(:), intent(inout):: percor
   end subroutine percorcalc
end interface

!write(0,*) "FCN1"

allocate(sol3(7+nbodies2*7))

j=0
do i=1,7+nbodies2*7
   sol3(i)=sol2(i)
enddo
do i=1,7+nbodies2*7
   if(serr2(i,2).ne.0.0d0)then
      j=j+1
      sol3(i)=x(j)
   endif
   write(0,501) sol3(i),sol2(i),sol3(i)-sol2(i),serr2(i,2)
enddo

!for percorcalc
allocate(percor(nbodies2))

!setting up percorcalc
tsamp=300.0/86400.0 !sampling [days]  !1-5 min seems to be fine for Kepler.
ts=minval(time2(1:npt))
te=maxval(time2(1:npt))
npt3=int((te-ts)/tsamp)+1
allocate(time3(npt3),itime3(npt3),ans3(npt3))
do i=1,npt3
   time3(i)=ts+dble(i)*tsamp
   itime3(i)=tsamp
enddo
itprint=0 !no output of timing measurements
itmodel=0 !do not need a transit model
percor=0.0d0 !initialize percor to zero.
call lcmodel(nbodies2,npt3,tol2,sol3,time3,itime3,percor,ans3,itprint,itmodel) !generate a LC model.
call percorcalc(nbodies2,sol3,percor)
itprint=1 !create output of timing measurements
itmodel=1 !calculate a transit model
call lcmodel(nbodies2,npt,tol2,sol3,time2,itime2,percor,fvec,itprint,itmodel)

!!write(0,*) "lcmodel",nbodies,npt
!call lcmodel(nbodies2,npt,tol2,sol3,time2,itime2,fvec)
!!write(0,*) "lcmodel done"

!nunit=10
!open(unit=nunit,file="junk.dat")
!do i=1,npt
!   write(nunit,501) time2(i),flux2(i),fvec(i)
!enddo
!close(nunit)
501 format(5(1X,1PE17.10))
write(0,*) "lcmodel in FCN done"
!read(5,*)

yp=1.0d0
do i=1,npt
   fvec(i)=(fvec(i)-flux2(i))/ferr2(i)*yp  !nope.. this is wrong..
enddo

return
end


