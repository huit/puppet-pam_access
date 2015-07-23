Facter.add(:pam_access) do
  confine :kernel => 'Linux'
  setcode do
    distid = Facter.value('lsbdistid')
    release = Facter.value('lsbmajdistrelease')
    case distid
    when /RedHatEnterprise|CentOS/
      release.to_i >= 6 ? true : false
    when /Ubuntu/
      release.to_i >= 10 ? true : false
    else
      false
    end
  end
end
