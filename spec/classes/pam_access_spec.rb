require 'spec_helper'

describe 'pam_access', :type => :class do
  describe 'does stuff if $::pam_access' do
    let(:facts) { { :pam_access => true } }
    let(:params) { { :exec => false } }

    it { should compile.with_all_deps }

    it do
      should contain_file('/etc/security/access.conf').with(
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644'
      )
    end

    describe 'execs authconfig-access' do
      let(:params) { { :exec => true } }

      it { should compile.with_all_deps }

      it do
        should contain_exec('authconfig-access').with(
          :command => 'authconfig --enablelocauthorize --enablepamaccess --update',
          :path => '/usr/bin:/usr/sbin:/bin',
          :unless => "grep '^account.*required.*pam_access.so' \
                      /etc/pam.d/system-auth 2>/dev/null"
        )
      end
    end
  end
end
