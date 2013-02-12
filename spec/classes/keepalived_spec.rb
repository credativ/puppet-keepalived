require 'spec_helper'
require 'rspec-hiera-puppet'

describe 'keepalived' do
    include_context "hieradata"
    
    let(:facts) { 
        {
            'hostname'  =>   'entry1',
            'fqdn'      =>   'entry1.testcluster.lan'
        }
    }

    id = 'keepalived'
    cfg = '/etc/keepalived/keepalived.conf'

    it "should contain Package[keepalived]" do
        should contain_package(id).with(
            {
                'ensure'    => 'present'
            }
        )
    end

    it "should contain File[keepalived.conf] with proper perms" do
        should contain_file(cfg).with(
            {
                'ensure'    => 'present',
                'owner'     => 'root',
                'group'     => 'root',
                'mode'      => '0644'
            }
        )
    end

    describe "various configuration tests" do
        it "contains notification_email" do
            should contain_file(cfg) \
                .with_content(/notification_email {\n.*root@localhost/)

        end
        it "contains correct notification_email_from" do
            should contain_file(cfg) \
                .with_content(/notification_email_from keepalived@entry1.testcluster.lan/)
        end

        it "contains vrrp_instances" do
            should contain_file(cfg).with_content(/vrrp_instance INTERN/)
            should contain_file(cfg).with_content(/vrrp_instance EXTERN/)
        end
    end

    it "should contain enabled Service[keepalived]" do
        should contain_service(id).with(
            {
                'ensure' => true,
                'enable' => true,
            }
        )
    end

    it "should contain stanca to enable ipvs module" do
        should contain_exec('enable_ipvs_module_load').with(
            {
                'command'         => '/bin/echo ip_vs >> /etc/modules',
                'unless'          => '/bin/grep -qF ip_vs /etc/modules'
            }
        )
    end

    context "keepalived on the MASTER node" do
        it do
            should contain_file(cfg)\
                .with_content(/state MASTER/)
        end
        it do
            should contain_file(cfg)\
                .with_content(/priority 150/)
        end
    end

    context "keepalived on the BACKUP node" do
        let(:facts) { 
            {
                'hostname'  =>   'entry2',
                'fqdn'      =>   'entry2.testcluster.lan'
            }
        }

        it do
            should contain_file(cfg)\
                .with_content(/state BACKUP/)
        end
        it do
            should contain_file(cfg)\
                .with_content(/priority 100/)
        end
    end   

    context "host is listed as disabled_hosts" do
        let(:params) {
            {
                'disabled_hosts'    => ['entry1']
            }
        }

        it do
            should contain_service(id).with(
                {
                    'ensure'    => 'stopped',
                    'enable'   => false
                }
            )
        end
    end
end
