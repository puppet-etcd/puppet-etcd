Puppet::Type.type(:etcd_key).provide(:etcdctl) do
  commands :etcdctl => '/usr/bin/etcdctl'

  def arguments
    args = ['--endpoints', @resource[:peers]]
    if @resource[:cert_file] && @resource[:key_file]
      args << '--cert' << @resource[:cert_file] << '--key' << @resource[:key_file]
    end

    if @resource[:ca_file]
      args << '--cacert' << @resource[:ca_file]
    end

    if @resource[:username] and @resource[:password]
      args << '--username' << @resource[:username]+":"+@resource[:password]
    end
    args
  end

  def exists?
    begin
      value
    rescue Puppet::ExecutionFailure => e
      return false
    end
    return true
  end

  def create
    # TODO: parametrize etcd version to keep compatibility with versions prior
    # to 3.4.1
    args = arguments
    args << 'put'  << @resource[:name] << @resource[:value]
    debug "[etcd create]: etcdctl #{args}\n"
    etcdctl(args)
  end

  def destroy
    args = arguments
    args << 'del'  << @resource[:name]
    debug "[etcd rm]: etcdctl #{args}\n"
    etcdctl(args)
  end

  def value
    args = arguments
    args << 'get'  << @resource[:name]
    debug "[etcd get]: etcdctl #{args}\n"
    etcdctl(args).chomp
  end

  def value=(val)
    args = arguments
    debug "[etcd set]: etcdctl #{args}\n"
    args << 'put'  << @resource[:name] << val
    etcdctl(args)
  end
end
