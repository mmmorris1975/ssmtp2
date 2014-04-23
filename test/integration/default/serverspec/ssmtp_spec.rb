require 'spec_helper'

describe file '/etc/ssmtp/ssmtp.conf' do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'mail' }
  it { should_not be_readable.by('others') }
  it { should_not be_writable.by('others') }

  its(:content) { should match(/^mailhub=localhost:25$/) }
  its(:content) { should match(/^AuthUser=my_user$/) }
  its(:content) { should match(/^AuthPass=my_password$/) }
  its(:content) { should match(/^AuthMethod=STARTTLS$/) }
  its(:content) { should match(/^FromLineOverride=YES$/) }
end
