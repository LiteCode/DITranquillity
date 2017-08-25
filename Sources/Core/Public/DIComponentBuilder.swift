//
//  DIComponentBuilder.swift
//  DITranquillity
//
//  Created by Alexander Ivlev on 10/06/16.
//  Copyright © 2016 Alexander Ivlev. All rights reserved.
//

/// Component Builder.
/// To create a used function `register(_:)` in class `ContainerBuilder`
/// The class allows you to configure all the necessary properties for the component
public final class DIComponentBuilder<Impl> {
  init(container: DIContainerBuilder, componentInfo: DIComponentInfo) {
    self.component = Component(componentInfo: componentInfo)
    container.components.insert(component)
  }
  
  deinit {
    var msg = component.isDefault ? "default " : ""
    msg += "registration: \(component.info)\n"
    msg += "\(DISetting.Log.tab)initial: \(nil != component.initial)\n"
    
    msg += "\(DISetting.Log.tab)lifetime: \(component.lifeTime)\n"
    msg += "\(DISetting.Log.tab)names: \(component.names)\n"
    msg += "\(DISetting.Log.tab)is default: \(component.isDefault)\n"
    
    msg += "\(DISetting.Log.tab)injections: \(component.injections.count)\n"
    
    log(.info, msg: msg)
  }
  
  let component: Component
}

// MARK: - contains `as` functions
public extension DIComponentBuilder {
  /// Function allows you to specify a type by which the component will be available
  /// Using:
  /// ```
  /// builder.register(YourClass.self)
  ///   .as(YourProtocol.self)
  /// ```
  ///
  /// - Parameter type: Type by which the component will be available
  /// - Returns: Self
  @discardableResult
  public func `as`<Parent>(_ type: Parent.Type) -> Self {
    component.names.insert(TypeKey(by: type))
    return self
  }
  
  /// Function allows you to specify a type with tag by which the component will be available
  /// Using:
  /// ```
  /// builder.register(YourClass.self)
  ///   .as(YourProtocol.self, tag: YourTag.self)
  /// ```
  ///
  /// - Parameters:
  ///   - type: Type by which the component will be available paired with tag
  ///   - tag: Tag by which the component will be available paired with type
  /// - Returns: Self
  @discardableResult
  public func `as`<Parent, Tag>(_ type: Parent.Type, tag: Tag.Type) -> Self {
    component.names.insert(TypeKey(by: type, and: tag))
    return self
  }
  
  /// Function allows you to specify a type with tag by which the component will be available
  /// Using:
  /// ```
  /// builder.register(YourClass.self)
  ///   .as(check: YourProtocol.self){$0}
  /// ```
  /// WHERE YourClass implements YourProtocol
  ///
  /// - Parameters:
  ///   - type: Type by which the component will be available paired with tag
  ///   - check: Validate type function. Always use `{$0}` for type validation
  /// - Returns: Self
  @discardableResult
  public func `as`<Parent>(check type: Parent.Type, _ check: (Impl)->Parent) -> Self {
    return self.as(type)
  }
  
  /// Function allows you to specify a type with tag by which the component will be available
  /// Using:
  /// ```
  /// builder.register(YourClass.self)
  ///   .as(check: YourProtocol.self, tag: YourTag.self){$0}
  /// ```
  /// WHERE YourClass implements YourProtocol
  ///
  /// - Parameters:
  ///   - type: Type by which the component will be available paired with tag
  ///   - tag: Tag by which the component will be available paired with type
  ///   - check: Validate type function. Always use `{$0}` for type validation
  /// - Returns: Self
  @discardableResult
  public func `as`<Parent, Tag>(check type: Parent.Type, tag: Tag.Type, _ check: (Impl)->Parent) -> Self {
    return self.as(type, tag: tag)
  }
}


// MARK: - contains `injection`, `postInit` functions
public extension DIComponentBuilder {
  /// Function for appending an injection method
  /// In addition, builder has a set of functions with a different number of parameters
  /// Using:
  /// ```
  /// builder.register(YourClass.self)
  ///   .injection{ $0.yourClassProperty = YourValue }
  /// ```
  /// Also see: `injection<Property>(cycle:_:)`
  ///
  /// - Parameter method: Injection method. First input argument is the always created object
  /// - Returns: Self
  @discardableResult
  public func injection(_ method: @escaping (Impl) -> ()) -> Self {
    component.append(injection: MethodMaker.make(true, by: method), cycle: false)
    return self
  }
  
  /// Function for appending an injection method
  /// In addition, builder has a set of functions with a different number of parameters
  ///
  /// Using:
  /// ```
  /// builder.register(YourClass.self)
  ///   .injection{ $0.yourClassProperty = $1 }
  /// ```
  /// OR
  /// ```
  /// builder.register(YourClass.self)
  ///   .injection{ yourClass, property in yourClass.property = property }
  /// ```
  /// OR if the injection participates in a cycle
  /// ```
  /// builder.register(YourClass.self)
  ///   .injection(cycle: true) { $0.yourClassProperty = $1 }
  /// ```
  ///
  /// - Parameters:
  ///   - cycle: true if the injection participates in a cycle. default false
  ///   - method: Injection method. First input argument is the always created object
  /// - Returns: Self
  @discardableResult
  public func injection<Property>(cycle: Bool = false, _ method: @escaping (Impl,Property) -> ()) -> Self {
    component.append(injection: MethodMaker.make(true, by: method), cycle: cycle)
    return self
  }
  
  /// Function for appending an injection method which is always executed at end of a object creation
  /// Using:
  /// ```
  /// builder.register(YourClass.self)
  ///   . ...
  ///   .postInit{ $0.postInitActions() }
  /// ```
  ///
  /// - Parameter method: Injection method. First input argument is the created object
  /// - Returns: Self
  @discardableResult
  public func postInit(_ method: @escaping (Impl) -> ()) -> Self {
    component.postInit = MethodMaker.make(true, by: method)
    return self
  }
}


// MARK: - contains `lifetime` and `default` functions
public extension DIComponentBuilder {
  /// Function to set lifetime of an object
  /// Using:
  /// ```
  /// builder.register(YourClass.self)
  ///   .lifetime(.prototype)
  /// ```
  ///
  /// - Parameter lifetime: LifeTime. for more information seeing enum `DILifeTime`
  /// - Returns: Self
  @discardableResult
  public func lifetime(_ lifetime: DILifeTime) -> Self {
    component.lifeTime = lifetime
    return self
  }
  
  /// Function declaring that this component will use the default
  /// This is necessary to resolve uncertainties if several components are availagle in the same type
  /// Using:
  /// ```
  /// builder.register(YourClass.self)
  ///   .default()
  /// ```
  ///
  /// - Returns: Self
  @discardableResult
  public func `default`() -> Self {
    component.isDefault = true
    return self
  }
}
