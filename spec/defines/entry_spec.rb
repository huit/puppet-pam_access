require 'spec_helper'

describe 'pam_access::entry', :type => :define do
  let(:title) { 'mailman-cron' }

  let(:params) { { :user => 'mailman', :origin => 'cron' } }

  it { should compile.with_all_deps }
end
