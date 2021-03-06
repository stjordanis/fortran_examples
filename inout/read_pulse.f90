program read_pulse

  implicit none

  integer, parameter :: idp = kind(1.0d0)
  real(idp) :: t(1199)
  real(idp) :: x(1199)
  real(idp) :: y(1199)
  integer :: n
  real(idp), allocatable :: t2(:), x2(:), y2(:)
  character(len=2) :: comment
  integer :: i, error

  ! Read in original pulse
  !
  ! Note that we assume that arrays t, x, y already have the correct size.
  ! This makes reading quite simple.
  open(110, file='pulse.dat', action='READ')
  i = 1
  do
    read(110,*,iostat=error) t(i), x(i), y(i)
    if (error == 0) then
      i = i + 1
    end if
    if (error < 0) exit ! end of file
    if (i > size(t)) exit
  end do
  close(110)

  ! Write it out
  !
  ! Good practice: In the first row of the file, write a comment of how many
  ! lines of data are in the file. That way, when we want to read in the file
  ! again, we can allocate the data arrays to the correct size before continuing
  ! to read data.
  !
  ! Also, *always* write a proper header to your data file, so that you know
  ! which column contains what later on
  open(110, file='pulse.out', action='WRITE')
  comment = "# "
  write(110, '(A2,I8," data rows")') comment, size(t)
  write(110, '(A2,A23,2A25)')                                                  &
  &    comment, "time [ns]", "Re(ampl) [MHz]", "Im(ampl) [MHz]"
  ! The columns labels will be right-adjusted. Note how 'A25' matches 'ES25.16'
  ! below.
  do i = 1, size(t)
    write(110, '(3ES25.16)') t(i), x(i), y(i)
  end do
  close(110)

  ! Read it in again -- without knowing the size a-priori
  !
  ! First, we read the size information from the commment in the first line, and
  ! allocate t2, x2, y2
  open(110, file='pulse.out', action='READ')
  read(110, *, iostat=error) comment, n ! remainder of line is ignored
  if (error == 0) then
    allocate(t2(n))
    allocate(x2(n))
    allocate(y2(n))
  else
    write(*,*) "No size information in file"
    stop
  end if
  ! Then, we read the actual data like before
  i = 1
  do
    read(110,*,iostat=error) t2(i), x2(i), y2(i)
    if (error == 0) then
      i = i + 1
    end if
    if (error < 0) exit ! end of file
    if (i > size(t)) exit
  end do
  close(110)

  ! Write it out once more (to check that everything was read correctly --
  ! pulse.out and pulse.out2 should be identical)
  open(110, file='pulse.out2', action='WRITE')
  comment = "# "
  write(110, '(A2,I8," data rows")') comment, size(t)
  write(110, '(A2,A23,2A25)')                                                  &
  &    comment, "time [ns]", "Re(ampl) [MHz]", "Im(ampl) [MHz]"
  do i = 1, size(t)
    write(110, '(3ES25.16)') t2(i), x2(i), y2(i)
  end do
  close(110)

  ! Clean up
  deallocate(t2, x2, y2)

end program read_pulse
