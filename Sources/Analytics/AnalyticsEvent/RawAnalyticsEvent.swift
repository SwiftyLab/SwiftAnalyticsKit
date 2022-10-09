/// An ``AnalyticsEvent`` type that can be initialized by name, group and configuration
/// parameters.
///
/// Use this type along with ``GlobalAnalyticsMetadata`` where creating a separate
/// ``AnalyticsEvent`` type doesn't make sense.
public protocol RawAnalyticsEvent<Name,Metadata>: AnalyticsEvent {
    /// Creates a new analytics event with provided name, group
    /// and configuration parameters.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - group: The group or set of groups event associated with.
    ///   - configuration: The configuration of event.
    init(
        name: Name,
        group: AnalyticsGroup,
        configuration: AnalyticsConfiguration
    )
}

public extension RawAnalyticsEvent {
    /// Creates a new analytics event with provided name.
    ///
    /// Default group ``AnalyticsGroup/action`` and
    /// ``DefaultConfiguration`` are used for
    /// the newly created event.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - group: The group or set of groups event associated with.
    ///   - configuration: The configuration of event.
    init(name: Name) {
        self.init(
            name: name,
            group: .action,
            configuration: DefaultConfiguration()
        )
    }

    /// Creates a new analytics event with provided parameters.
    ///
    /// If name isn't provided, default initializer is used for the event name.
    /// Default group ``AnalyticsGroup/action`` and ``DefaultConfiguration``
    /// are used if group and configuration not specified respectively.
    ///
    /// - Parameters:
    ///   - name: The event name.
    ///   - group: The group or set of groups event associated with.
    ///   - configuration: The configuration of event.
    ///
    /// - Returns: Newly created analytics event.
    static func some(
        name: Name = .init(),
        group: AnalyticsGroup = .action,
        configuration: AnalyticsConfiguration = DefaultConfiguration()
    ) -> Self where Name: Initializable {
        return Self(name: name, group: group, configuration: configuration)
    }
}

public extension RawAnalyticsEvent where Name: Initializable {
    /// Creates a new empty name analytics event.
    init() {
        self.init(name: .init())
    }
}

public extension RawAnalyticsEvent {
    /// Creates a new analytics event from the provided event.
    ///
    /// Optional group and configuration parameter can be provided to customize
    /// associated group and configuration of new event.
    ///
    /// - Parameters:
    ///   - event: The event to create from.
    ///   - group: The optional group to which newly created event will be transferred.
    ///            If `nil` then the newly created event is associated with the provided
    ///            event's group.
    ///   - configuration: The optional configuration for newly created event.
    ///                    If `nil` configuration is kept from provided event.
    init<Event: AnalyticsEvent>(
        from event: Event,
        transferredTo group: AnalyticsGroup? = nil,
        configuration: AnalyticsConfiguration? = nil
    ) where Event.Name == Name {
        self.init(
            name: event.name,
            group: group ?? event.group,
            configuration: configuration ?? event.configuration
        )
    }
    /// Creates a new analytics event from the provided event.
    ///
    /// Additional group and optional configuration parameter can be provided to
    /// associate new event with additional groups along with provided event's groups
    /// and customize configuration of new event respectively.
    ///
    /// - Parameters:
    ///   - event: The event to create from.
    ///   - group: The additional group or set of groups to which newly created
    ///            event will also be associated along with provided event's groups.
    ///   - configuration: The optional configuration for newly created event.
    ///                    If `nil` configuration is kept from provided event.
    init<Event: AnalyticsEvent>(
        from event: Event,
        appending group: AnalyticsGroup,
        configuration: AnalyticsConfiguration? = nil
    ) where Event.Name == Name {
        self.init(
            name: event.name,
            group: event.group.union(group),
            configuration: configuration ?? event.configuration
        )
    }
    /// Creates a new analytics event from the provided event.
    ///
    /// Optional group and configuration parameter can be provided to customize
    /// associated group and configuration of new event.
    ///
    /// - Parameters:
    ///   - event: The event to create from.
    ///   - group: The optional group to which newly created event will be transferred.
    ///            If `nil` then the newly created event is associated with the provided
    ///            event's group.
    ///   - configuration: The optional configuration for newly created event.
    ///                    If `nil` configuration is kept from provided event.
    init<Event: AnalyticsEvent>(
        from event: Event,
        transferredTo group: AnalyticsGroup? = nil,
        configuration: AnalyticsConfiguration? = nil
    ) where Event.Name == Name, Event.Metadata == Metadata {
        self.init(
            name: event.name,
            group: group ?? event.group,
            configuration: configuration ?? event.configuration
        )
    }
    /// Creates a new analytics event from the provided event.
    ///
    /// Additional group and optional configuration parameter can be provided to
    /// associate new event with additional groups along with provided event's groups
    /// and customize configuration of new event respectively.
    ///
    /// - Parameters:
    ///   - event: The event to create from.
    ///   - group: The additional group or set of groups to which newly created
    ///            event will also be associated along with provided event's groups.
    ///   - configuration: The optional configuration for newly created event.
    ///                    If `nil` configuration is kept from provided event.
    init<Event: AnalyticsEvent>(
        from event: Event,
        appending group: AnalyticsGroup,
        configuration: AnalyticsConfiguration? = nil
    ) where Event.Name == Name, Event.Metadata == Metadata {
        self.init(
            name: event.name,
            group: event.group.union(group),
            configuration: configuration ?? event.configuration
        )
    }
}

public extension RawAnalyticsEvent
where Name: ExpressibleByUnicodeScalarLiteral {
    /// Creates a new analytics event from a name with string literal containing a single Unicode
    /// scalar value.
    ///
    /// Default group ``AnalyticsGroup/action`` and ``DefaultConfiguration``
    /// is used for the newly created event
    ///
    /// - Parameter value: The event name value of the new instance.
    init(unicodeScalarLiteral value: Name.UnicodeScalarLiteralType) {
        self.init(name: .init(unicodeScalarLiteral: value))
    }
}

public extension RawAnalyticsEvent
where Name: ExpressibleByExtendedGraphemeClusterLiteral {
    /// Creates a new analytics event from a name with string literal containing a single extended
    /// grapheme cluster.
    ///
    /// Default group ``AnalyticsGroup/action`` and ``DefaultConfiguration``
    /// is used for the newly created event
    ///
    /// - Parameter value: The event name value of the new instance.
    init(
        extendedGraphemeClusterLiteral value: Name
            .ExtendedGraphemeClusterLiteralType
    ) {
        self.init(name: .init(extendedGraphemeClusterLiteral: value))
    }
}

public extension RawAnalyticsEvent where Name: ExpressibleByStringLiteral {
    /// Creates a new analytics event from a name with string literal.
    ///
    /// Default group ``AnalyticsGroup/action`` and ``DefaultConfiguration``
    /// is used for the newly created event
    ///
    /// - Parameter value: The event name value of the new instance.
    init(stringLiteral value: Name.StringLiteralType) {
        self.init(name: .init(stringLiteral: value))
    }
}
